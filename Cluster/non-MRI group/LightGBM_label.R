rm(list = ls())
set.seed(43)

library(lightgbm)
library(dplyr)
library(rpart.plot)
library(SHAPforxgboost)
library(shapviz)
library(pROC)
library(caret)
library(data.table)
require(RColorBrewer)
Project_path = 'Work_path'
source(paste(Project_path,'Packages/SHAP_functions.R',sep = '/'))

save_path = paste(Project_path,'Cluster/non-MRI group',sep = '/')
Feature_MRI_dir <- paste(Project_path,'Data/Population/MRI group/Traits.csv',sep = "/")
Feature_nonMRI_dir <- paste(Project_path,'Data/Population/nonMRI group/Traits.csv',sep = "/")
type1_id_dir <- paste(Project_path,'Cluster/MRI group/type1_eid.csv',sep = "/")
type2_id_dir <- paste(Project_path,'Cluster/MRI group/type2_eid.csv',sep = "/")
FeatureName_dir <- paste(Project_path,'Data/Population/FeatureName.csv',sep = "/")

Feature_diff = as.data.frame(read_excel(paste(Project_path,'Cluster/MRI group/Feature_diff.xlsx',sep = "/")))
Feature_diff = Feature_diff[-c(1:5),]
Feature_MRI <- as.data.frame(fread(Feature_MRI_dir))
Feature_nonMRI <- as.data.frame(fread(Feature_nonMRI_dir))
ori_FeatureName = names(Feature_MRI)[2:183]
FeatureName <- names(as.data.frame(fread(FeatureName_dir)))
names(Feature_MRI) = FeatureName
names(Feature_nonMRI) = FeatureName
Sig_indx = Feature_diff$Cluter_Feature
Feature_MRI <- Feature_MRI[,c(T,Sig_indx)]
Feature_nonMRI <- Feature_nonMRI[,c(T,Sig_indx)]

type1_id <- as.data.frame(fread(type1_id_dir))
colnames(type1_id) = 'eid'
type2_id <- as.data.frame(fread(type2_id_dir))
colnames(type2_id) = 'eid'

# 使用merge函数根据eid合并两个数据框
Feature_type1 <- merge(Feature_MRI, type1_id, by = "eid")
Feature_type2 <- merge(Feature_MRI, type2_id, by = "eid")

Train_Feature <- subset(bind_rows(Feature_type1, Feature_type2),select = -c(eid)) 
Train_Feature$label = c(rep(0, times = nrow(Feature_type1)),rep(1, times = nrow(Feature_type2)))

features <- setdiff(names(Train_Feature), c("eid","label"))


params <- list(
  objective = "regression",
  num_leaves = 20,
  learning_rate = 0.02,
  num_iterations = 500,
  min_data_in_leaf = 30,
  feature_pre_filter = FALSE,
  verbosity = 0
)


fold_n = 10
threshold <- 0.5
fold_index <- createFolds(Feature_MRI$eid, k=fold_n, returnTrain=T)
auc_values <- numeric(fold_n)


roc_list = list()
for( n in 1 : fold_n){
  fold = names(fold_index)[n]
  training_lgb <- lgb.Dataset(data = as.matrix(Train_Feature[fold_index[[fold]], features]), 
                              label = Train_Feature$label[fold_index[[fold]]], params = params)
  # train model
  model <- lgb.train(params, data = training_lgb)
  Predictions_test <- predict(object = model, 
                              newdata = as.matrix(Train_Feature[-fold_index[[fold]], features]))
  
  predictions_label <- ifelse(Predictions_test > threshold, 1, 0)
  roc_obj <- roc(Train_Feature$label[-fold_index[[fold]]], Predictions_test)
  auc_values[n] <- roc_obj$auc
  roc_list[[n]] <- roc_obj
}

# Calculate the mean and standard errors of the AUC values
auc_mean <- mean(auc_values)
auc_sd <- sd(auc_values)

# Create a data.frame to store all folded ROC data
roc_data <- do.call(rbind, lapply(1:fold_n, function(i) {
  roc_curve <- roc_list[[i]]
  data.frame(
    Fold = paste0("", i),
    FalsePositiveRate = 1 - roc_curve$specificities,
    TruePositiveRate = roc_curve$sensitivities,
    Threshold = roc_curve$thresholds
  )
}))
roc_data$Fold <- factor(roc_data$Fold, levels = c("1", "2","3", "4","5", "6","7", "8","9", "10"))
save(roc_data, file = paste(save_path,"roc_data.RData",sep = "/"))
# load(file = paste(save_path,"roc_data.RData",sep = "/"))

# 使用ggplot2绘制ROC曲线，并设置图例标签竖排
p <- ggplot(roc_data, aes(x = FalsePositiveRate, y = TruePositiveRate, color = Fold, group = Fold)) +
  geom_line(linewidth = 1.0) +
  scale_color_viridis_d() +
  labs(x = "False Positive Rate", y = "True Positive Rate", 
       title = "ROC Curves for 10 Folds") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = "white"),
        panel.background = element_rect(fill = "white", color = "white"),
        axis.line = element_line(color = "black", linewidth = 1),
        legend.text = element_text(size=20),
        legend.title = element_text(size=20),
        legend.key.size = unit(0.3, "inches"),
        plot.title = element_text(hjust = 0.5,size = 25),
        axis.title.x = element_text(size = 20, color = "black"),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.text.x = element_text(size = 20, color = "black"),
        axis.text.y = element_text(size = 20, color = "black")) +  
  ylim(0,1)+
  guides(color = guide_legend(direction = "vertical",
                              label.theme = element_text(angle = 0, hjust = 1))
  )+ annotate("text", x = 0.15,  y = 0.3, 
              label = paste("AUC:", round(auc_mean, 2), "±", round(auc_sd, 3)), 
              vjust = 1, hjust = 0, 
              size = 10, color = "black", angle = 0)
ggsave(paste(save_path,'roc_Image.png',sep = '/'), p, dpi = 500, width = 180, height = 160, units = "mm")


Image_lgb <- lgb.Dataset(data = as.matrix(Train_Feature[, features]), 
                         label = Train_Feature$label, params = params)
# train model
best_opt_model <- lgb.train(params, data = Image_lgb)
Predictions_UKB <- predict(object = best_opt_model,newdata = as.matrix(Feature_nonMRI[, features]))

Predictions_UKB_label = subset(Feature_nonMRI,select = c(eid)) 
Predictions_UKB_label$label <- ifelse(Predictions_UKB > threshold, 1, 0)

write.table(x = Predictions_UKB_label,
            file = paste(save_path,"UKB_label.csv",sep = "/"), 
            col.names = T, 
            row.names = F, 
            quote = F, 
            sep = ",")

## SHAP on UKB data ##
UKB_shap_values <- shapviz(best_opt_model, X_pred = as.matrix(Feature_nonMRI[, features]))
save(UKB_shap_values, file = paste(save_path,"UKB_shap_values.RData",sep = "/"))
# write.table(x = UKB_shap_values$S,
#             file = paste(save_path,"UKB_shap_values.csv",sep = "/"), 
#             col.names = T, 
#             row.names = F, 
#             quote = F, 
#             sep = ",")

# result from individual SHAPs averaged across all outer CVs for the five different models
UKB_mean_shap_score <- colMeans(abs(UKB_shap_values$S))[order(colMeans(abs(UKB_shap_values$S)), decreasing = T)]
UBK_shap_results <- list(shap_score = UKB_shap_values$S, mean_shap_score = (UKB_mean_shap_score))

#print SHAP feature importance 
png(filename=paste(save_path,"UKB_SHAP_mean_top40_test_.png",sep = "/")) 
var_importance(UBK_shap_results, top_n=40) 
dev.off()

# plot SHAP beeswarm
UKB_shap_long = shap.prep(shap_contrib = as.data.frame(UKB_shap_values$S),
                          X_train = UKB_shap_values$X,
                          top_n = 40) 
save(UKB_shap_long, file = paste(save_path,"UKB_shap_long.RData",sep = "/"))
# load(file = paste(save_path,"UKB_shap_long.RData",sep = "/"))

UKB_shap_long$variable <- gsub('_',' ',UKB_shap_long$variable)
UKB_shap_long$variable <- gsub('pm2 5','pm2.5',UKB_shap_long$variable)
UKB_shap_long$variable <- gsub('Average total household income before tax Greater than 100 000 ','Income greater than 100000',UKB_shap_long$variable)

p <- plot.shap.summary(data_long = UKB_shap_long)
ggsave(paste(save_path,'UKB_SHAP_beeswarm_top40.png',sep = '/'), p, dpi = 500, width = 200, height = 150, units = "mm")

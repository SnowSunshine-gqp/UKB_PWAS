rm(list = ls())
library(data.table)
library(tibble)
library(mediation)
library(bruceR)
library(openxlsx)
Projcet_path = 'Work_path'
save_path = paste(Projcet_path,'Mediate analysis/new_Mediation',sep = '/')
File_path = paste(Projcet_path,'Mediate analysis/MDD_tbl.csv',sep = '/')

df <- as.data.frame(fread(File_path))
colnames(df)[2] = 'PRS_MDD'
Type1 = read.csv(paste(Projcet_path,'Cluster/Group1/type1_eid.csv',sep = '/'), col.names = 'eid', header = F)
Type2 = read.csv(paste(Projcet_path,'Cluster/Group1/type2_eid.csv',sep = '/'), col.names = 'eid', header = F)
df1 = df[df$eid %in% Type1$eid,]
df2 = df[df$eid %in% Type2$eid,]

# colnames(df)
Threshold = 0.05
Threshold_182 = 0.05 / 182
Threshold_43 = 0.05 / 43

X.names<- colnames(df[c(2)]) #
M.names<- colnames(df[c(3:184)]) #
Y.names <- colnames(df[185:227]) #

X.n = length(X.names)
M.n = length(M.names)
Y.n = length(Y.names)

Result_Total = data.frame()
Result_Type1 = data.frame()
Result_Type2 = data.frame()
for (i in 1:X.n ){
  for (j in 1 : M.n){
    Total.M <- summary(lm(formula = paste(M.names[j], '~', X.names[i]), data = df))
    Total.a <- Total.M$coefficients[X.names[i],]
    
    Type1.M <- summary(lm(formula = paste(M.names[j], '~', X.names[i]), data = df1))
    Type1.a <- Type1.M$coefficients[X.names[i],]
    
    Type2.M <- summary(lm(formula = paste(M.names[j], '~', X.names[i]), data = df2))
    Type2.a <- Type2.M$coefficients[X.names[i],]
    
    if (Total.a['Pr(>|t|)'] < Threshold_182 | Type1.a['Pr(>|t|)'] < Threshold_182 | Type2.a['Pr(>|t|)'] < Threshold_182 ){# 如果a 显著
      for (k in 1:Y.n ) {
        Total.Y <- summary(lm(formula = paste(Y.names[k], '~', X.names[i],'+',M.names[j]), data = df))
        Total.b <- Total.Y$coefficients[M.names[j],]# b
        Total.c = Total.Y$coefficients[X.names[i],]# c'
        
        Type1.Y <- summary(lm(formula = paste(Y.names[k], '~', X.names[i],'+',M.names[j]), data = df1))
        Type1.b <- Type1.Y$coefficients[M.names[j],]# b
        Type1.c = Type1.Y$coefficients[X.names[i],]# c'
        
        Type2.Y <- summary(lm(formula = paste(Y.names[k], '~', X.names[i],'+',M.names[j]), data = df2))
        Type2.b <- Type2.Y$coefficients[M.names[j],]# b
        Type2.c = Type2.Y$coefficients[X.names[i],]# c'
        
        if (Total.b['Pr(>|t|)'] < Threshold_43 | Type1.b['Pr(>|t|)'] < Threshold_43 | Type2.b['Pr(>|t|)'] < Threshold_43){# 如果b 显著
          Total.Meditor <- PROCESS(df, y = Y.names[k], x = X.names[i], meds = M.names[j], ci="bca.boot", nsim=1000, seed =1)
          Total.ab = Total.Meditor$results[[1]]$mediation['Indirect (ab)',]# ab
          Total.cc = Total.Meditor$results[[1]]$mediation["Direct (c')",]# c'
          Total.c = Total.Meditor$results[[1]]$mediation["Total (c)",]# c
          
          Type1.Meditor <- PROCESS(df1, y = Y.names[k], x = X.names[i], meds = M.names[j], ci="bca.boot", nsim=1000, seed =1)
          Type1.ab = Type1.Meditor$results[[1]]$mediation['Indirect (ab)',]# ab
          Type1.cc = Type1.Meditor$results[[1]]$mediation["Direct (c')",]# c'
          Type1.c = Type1.Meditor$results[[1]]$mediation["Total (c)",]# c
          
          Type2.Meditor <- PROCESS(df2, y = Y.names[k], x = X.names[i], meds = M.names[j], ci="bca.boot", nsim=1000, seed =1)
          Type2.ab = Type2.Meditor$results[[1]]$mediation['Indirect (ab)',]# ab
          Type2.cc = Type2.Meditor$results[[1]]$mediation["Direct (c')",]# c'
          Type2.c = Type2.Meditor$results[[1]]$mediation["Total (c)",]# c
          
          if (Total.ab$pval < Threshold_43 | Type1.ab$pval < Threshold_43 | Type2.ab$pval < Threshold_43){# 中介ab 显著是分析的前提
            # Total
            if (Total.ab$Effect * Total.cc$Effect < 0){# 中介遮掩
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Total.a[1],
                "a Pvalue" = Total.a[4],
                "b effect" = Total.b[1],
                "b Pvalue" = Total.b[4],
                "percent" = -100 * abs(Total.ab$Effect / ( abs(Total.c$Effect) +  abs(Total.ab$Effect) ) ),
                "ab effect" = Total.ab$Effect,
                "ab 90% CI" = Total.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Total.ab$pval,
                "c' effect" = Total.cc$Effect,
                "c' 90% CI" = Total.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Total.cc$pval,
                "c effect" = Total.c$Effect,
                "c 90% CI" = Total.c$`[MCMC 95% CI]`,
                "c Pvalue" = Total.c$pval,
                "types" = 'Suppression'
              )
            }else{# 中介部分/完全
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Total.a[1],
                "a Pvalue" = Total.a[4],
                "b effect" = Total.b[1],
                "b Pvalue" = Total.b[4],
                "percent" = 100 * Total.ab$Effect / Total.c$Effect,
                "ab effect" = Total.ab$Effect,
                "ab 90% CI" = Total.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Total.ab$pval,
                "c' effect" = Total.cc$Effect,
                "c' 90% CI" = Total.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Total.cc$pval,
                "c effect" = Total.c$Effect,
                "c 90% CI" = Total.c$`[MCMC 95% CI]`,
                "c Pvalue" = Total.c$pval,
                "types" = if_else(Total.cc$pval < Threshold_43, 'Part', 'Complete')# 判别中介类型：部分/完全
              )
            }# 结束else Total
            Result_Total = rbind(Result_Total, temp_result)
            # Type1
            if (Type1.ab$Effect * Type1.cc$Effect < 0){# 中介遮掩
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Type1.a[1],
                "a Pvalue" = Type1.a[4],
                "b effect" = Type1.b[1],
                "b Pvalue" = Type1.b[4],
                "percent" = -100 * abs(Type1.ab$Effect / ( abs(Type1.c$Effect) +  abs(Type1.ab$Effect) ) ),
                "ab effect" = Type1.ab$Effect,
                "ab 90% CI" = Type1.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Type1.ab$pval,
                "c' effect" = Type1.cc$Effect,
                "c' 90% CI" = Type1.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Type1.cc$pval,
                "c effect" = Type1.c$Effect,
                "c 90% CI" = Type1.c$`[MCMC 95% CI]`,
                "c Pvalue" = Type1.c$pval,
                "types" = 'Suppression'
              )
            }else{# 中介部分/完全
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Type1.a[1],
                "a Pvalue" = Type1.a[4],
                "b effect" = Type1.b[1],
                "b Pvalue" = Type1.b[4],
                "percent" = 100 * Type1.ab$Effect / Type1.c$Effect,
                "ab effect" = Type1.ab$Effect,
                "ab 90% CI" = Type1.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Type1.ab$pval,
                "c' effect" = Type1.cc$Effect,
                "c' 90% CI" = Type1.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Type1.cc$pval,
                "c effect" = Type1.c$Effect,
                "c 90% CI" = Type1.c$`[MCMC 95% CI]`,
                "c Pvalue" = Type1.c$pval,
                "types" = if_else(Type1.cc$pval < Threshold_43, 'Part', 'Complete')# 判别中介类型：部分/完全
              )
            }# 结束else Type1
            Result_Type1 = rbind(Result_Type1, temp_result)
            # Type2
            if (Type2.ab$Effect * Type2.cc$Effect < 0){# 中介遮掩
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Type2.a[1],
                "a Pvalue" = Type2.a[4],
                "b effect" = Type2.b[1],
                "b Pvalue" = Type2.b[4],
                "percent" = -100 * abs(Type2.ab$Effect / ( abs(Type2.c$Effect) +  abs(Type2.ab$Effect) ) ),
                "ab effect" = Type2.ab$Effect,
                "ab 90% CI" = Type2.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Type2.ab$pval,
                "c' effect" = Type2.cc$Effect,
                "c' 90% CI" = Type2.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Type2.cc$pval,
                "c effect" = Type2.c$Effect,
                "c 90% CI" = Type2.c$`[MCMC 95% CI]`,
                "c Pvalue" = Type2.c$pval,
                "types" = 'Suppression'
              )
            }else{# 中介部分/完全
              temp_result = tibble(
                "Disorder" = X.names[i],
                "Mediators" = M.names[j],
                "Brain region" = Y.names[k],
                "a effect" = Type2.a[1],
                "a Pvalue" = Type2.a[4],
                "b effect" = Type2.b[1],
                "b Pvalue" = Type2.b[4],
                "percent" = 100 * Type2.ab$Effect / Type2.c$Effect,
                "ab effect" = Type2.ab$Effect,
                "ab 90% CI" = Type2.ab$`[MCMC 95% CI]`,
                "ab Pvalue" = Type2.ab$pval,
                "c' effect" = Type2.cc$Effect,
                "c' 90% CI" = Type2.cc$`[MCMC 95% CI]`,
                "c' Pvalue" = Type2.cc$pval,
                "c effect" = Type2.c$Effect,
                "c 90% CI" = Type2.c$`[MCMC 95% CI]`,
                "c Pvalue" = Type2.c$pval,
                "types" = if_else(Type2.cc$pval < Threshold_43, 'Part', 'Complete')# 判别中介类型：部分/完全
              )
            }# 结束else Type2
            Result_Type2 = rbind(Result_Type2, temp_result)
            
          }# 结束中介结果输出
          
        }# 结束 b显著的情况
      }# 结束 脑区循环
    }# 结束 a显著的情况
    
  }# 结束 中介m循环
}# 结束 prs循环

if (!dir.exists(save_path)){
  dir.create(save_path)
}
xlsx_path = paste(save_path,'MDD_Mediation_Result_Total.xlsx',sep = '/')
write.xlsx(Result_Total, xlsx_path, sheetName = "sheet1", colNames = TRUE, rowNames = TRUE)

xlsx_path = paste(save_path,'MDD_Mediation_Result_Type1.xlsx',sep = '/')
write.xlsx(Result_Type1, xlsx_path, sheetName = "sheet1", colNames = TRUE, rowNames = TRUE)

xlsx_path = paste(save_path,'MDD_Mediation_Result_Type2.xlsx',sep = '/')
write.xlsx(Result_Type2, xlsx_path, sheetName = "sheet1", colNames = TRUE, rowNames = TRUE)


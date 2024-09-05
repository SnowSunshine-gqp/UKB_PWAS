rm(list = ls())
library(data.table)
library(ggplot2)
library(openxlsx)
library(tidyr)
library(dplyr)
library(extrafont)
loadfonts(device = "pdf")

Projcet_path = 'Work_path'
save_path <- paste(Projcet_path,'Mediation analysis/Display/Figure',sep = '/')
save_dir <- paste(Projcet_path,'Mediation analysis/Display/result.xlsx',sep = '/')

File_path = paste(Projcet_path,'Mediation analysis/Significant Traits/Result',sep = '/')

Threshold = 0.05/43
PRS_names <- dir(File_path)
PRS_n = length(PRS_names)
list1 = list()

load(file = paste(Projcet_path,'Data/Images/Stand_region_name.Rdata',sep = '/'))
########
# Stand_region_name = c("Total volume",
#                       "Cortical volume",
#                       "Caudal anterior cingulate",
#                       "Caudal middle frontal",
#                       "Cuneus",
#                       "Entorhinal",
#                       "Fusiform",
#                       "Inferior parietal",
#                       "Inferior temporal",
#                       "Isthmus cingulate",
#                       "Lateral occipital",
#                       "Lateral orbitofrontal",
#                       "Lingual",
#                       "Medial orbitofrontal",
#                       "Middle temporal",
#                       "Parahippocampal",
#                       "Paracentral",
#                       "Pars opercularis",
#                       "Pars orbitalis",
#                       "Pars triangularis",
#                       "Pericalcarine",
#                       "Postcentral",
#                       "Posterior cingulate",
#                       "Precentral",
#                       "Precuneus",
#                       "Rostral anterior cingulate",
#                       "Rostral middle frontal",
#                       "Superior frontal",
#                       "Superior parietal",
#                       "Superior temporal",
#                       "Supramarginal",
#                       "Transverse temporal",
#                       "Insula",
#                       "Subcortical volume",
#                       "Accumbens",
#                       "Amygdala",
#                       "Caudate",
#                       "Hippocampus",
#                       "Putamen",
#                       "Thalamus",
#                       "Pallidum",
#                       "Lateral ventricle",
#                       "Cerebellum")
# save(... = Stand_region_name,file = paste(Projcet_path,'Data/Images/Stand_region_name.Rdata',sep = '/'))
# write.csv(x = Stand_region_name,file = paste(Projcet_path,'Data/Images/Stand_region_name.csv',sep = '/'))
########
for (n in seq(PRS_n)){
  temp_path = paste(File_path,PRS_names[n],'Mediation.xlsx',sep = '/')
  tbl_a <- read.xlsx(temp_path, sheet = "a",colNames = T)
  tbl_b_E <- read.xlsx(temp_path, sheet = "b Effect",colNames = T)
  tbl_b_P <- read.xlsx(temp_path, sheet = "b Pvalue",colNames = T)
  tbl_ab_P <- read.xlsx(temp_path, sheet = "ab Pvalue",colNames = T)
  tbl_ab_E <- read.xlsx(temp_path, sheet = "ab Effect",colNames = T)
  tbl_c_E <- read.xlsx(temp_path, sheet = "c Effect",colNames = T)
  tbl_c_P <- read.xlsx(temp_path, sheet = "c Pvalue",colNames = T)
  tbl_cc_E <- read.xlsx(temp_path, sheet = "cc Effect",colNames = T)
  tbl_cc_P <- read.xlsx(temp_path, sheet = "cc Pvalue",colNames = T)
  
  colnames(tbl_c_E)[1] <- "Region"
  colnames(tbl_c_P)[1] <- "Region"
  colnames(tbl_cc_E)[1] <- "Region"
  colnames(tbl_cc_P)[1] <- "Region"
  colnames(tbl_b_P)[1] <- "Region"
  colnames(tbl_b_E)[1] <- "Region"
  colnames(tbl_ab_P)[1] <- "Region"
  colnames(tbl_ab_E)[1] <- "Region"
  
  Trait_name <- gsub("_",' ',colnames(tbl_ab_E))
  Trait_name <- gsub("\\.", '', Trait_name)
  
  colnames(tbl_ab_E) <- Trait_name
  colnames(tbl_ab_P) <- Trait_name
  colnames(tbl_b_E) <- Trait_name
  colnames(tbl_b_P) <- Trait_name
  colnames(tbl_c_E) <- Trait_name
  colnames(tbl_c_P) <- Trait_name
  colnames(tbl_cc_E) <- Trait_name
  colnames(tbl_cc_P) <- Trait_name
  
  Region_name <- gsub("_",' ',tbl_ab_E$Region)
  tbl_ab_P$Region <- Stand_region_name
  tbl_ab_E$Region <- Stand_region_name
  tbl_b_P$Region <- Stand_region_name
  tbl_b_E$Region <- Stand_region_name
  tbl_c_P$Region <- Stand_region_name
  tbl_c_E$Region <- Stand_region_name
  tbl_cc_P$Region <- Stand_region_name
  tbl_cc_E$Region <- Stand_region_name
  
  pass_indices <- c('Region',colnames(tbl_ab_P %>% select(where(~ any(. <= Threshold)))))
  
  tbl_Pass_ab_E <- tbl_ab_E %>% select(all_of(pass_indices))
  tbl_Pass_ab_P <- tbl_ab_P %>% select(all_of(pass_indices))
  tbl_Pass_b_E <- tbl_b_E %>% select(all_of(pass_indices))
  tbl_Pass_b_P <- tbl_b_P %>% select(all_of(pass_indices))
  tbl_Pass_c_E <- tbl_c_E %>% select(all_of(pass_indices))
  tbl_Pass_c_P <- tbl_c_P %>% select(all_of(pass_indices))
  tbl_Pass_cc_E <- tbl_cc_E %>% select(all_of(pass_indices))
  tbl_Pass_cc_P <- tbl_cc_P %>% select(all_of(pass_indices))
  
  tbl_Pass_ab_E_long <- gather(tbl_Pass_ab_E,key = "Trait",value = 'ab_effect',-Region)
  tbl_Pass_ab_P_long <- gather(tbl_Pass_ab_P,key = "Trait",value = 'ab_pvalue',-Region)
  tbl_Pass_b_E_long <- gather(tbl_Pass_b_E,key = "Trait",value = 'b_effect',-Region)
  tbl_Pass_b_P_long <- gather(tbl_Pass_b_P,key = "Trait",value = 'b_pvalue',-Region)
  tbl_Pass_c_E_long <- gather(tbl_Pass_c_E,key = "Trait",value = 'c_effect',-Region)
  tbl_Pass_c_P_long <- gather(tbl_Pass_c_P,key = "Trait",value = 'c_pvalue',-Region)
  tbl_Pass_cc_E_long <- gather(tbl_Pass_cc_E,key = "Trait",value = 'cc_effect',-Region)
  tbl_Pass_cc_P_long <- gather(tbl_Pass_cc_P,key = "Trait",value = 'cc_pvalue',-Region)
  
  tbl_combined <- cbind(tbl_Pass_b_E_long,
                        b_pvalue = tbl_Pass_b_P_long$b_pvalue,
                        ab_effect = tbl_Pass_ab_E_long$ab_effect,
                        ab_pvalue = tbl_Pass_ab_P_long$ab_pvalue,
                        c_effect = tbl_Pass_c_E_long$c_effect,
                        c_pvalue = tbl_Pass_c_P_long$c_pvalue,
                        cc_effect = tbl_Pass_cc_E_long$cc_effect,
                        cc_pvalue = tbl_Pass_cc_P_long$cc_pvalue) 
  
  a_trait_name = gsub("_",' ',colnames(tbl_a[2:ncol(tbl_a)]))
  biomarker_names <- gsub("\\.", '', a_trait_name)
  
  tbl_combined$a_effect <- NA
  tbl_combined$a_pvalue <- NA
  for (i in seq_along(tbl_combined$Region)) {
    tbl_combined$a_effect[i] <- tbl_a[1,1 + match(tbl_combined$Trait[i], biomarker_names)]
    tbl_combined$a_pvalue[i] <- tbl_a[2,1 + match(tbl_combined$Trait[i], biomarker_names)]
  }
  tbl_combined$percent = 0
  tbl_combined$text <-  NA
  # 完全中介
  indx0 = tbl_combined$ab_pvalue < Threshold & tbl_combined$cc_pvalue > Threshold  & tbl_combined$ab_effect * tbl_combined$cc_effect > 0
  percent0 = 100* tbl_combined$ab_effect[indx0] / tbl_combined$c_effect[indx0]
  tbl_combined$percent[indx0] = percent0
  # 部分中介效应
  indx1 = tbl_combined$ab_pvalue < Threshold & tbl_combined$cc_pvalue < Threshold & tbl_combined$ab_effect * tbl_combined$cc_effect > 0
  tbl_combined$percent[indx1] = 100* tbl_combined$ab_effect[indx1] / tbl_combined$c_effect[indx1]
  
  # 遮掩效应 c显著 部分
  indx2 = tbl_combined$ab_pvalue < Threshold & tbl_combined$cc_effect < Threshold & tbl_combined$ab_effect * tbl_combined$cc_effect < 0
  tbl_combined$percent[indx2] = -100* tbl_combined$ab_effect[indx2] / (abs(tbl_combined$cc_effect[indx2]) + abs(tbl_combined$ab_effect[indx2]))
  
  bold_indx = indx0 | indx1 | indx2
  tbl_combined$bold = bold_indx
  
  # 删去无关traits
  trait_count <- table(tbl_combined$Trait[!bold_indx])
  tbl_combined1 <- tbl_combined
  if (sum(trait_count== 43) != 0){
    tbl_combined1 <- tbl_combined1[!tbl_combined1$Trait %in% rownames(trait_count)[trait_count == 43], ]
  }
tbl_combined1$text = formatC(10000 * tbl_combined1$ab_effect, digits = 2, format = "f", zero.print = TRUE, drop0trailing = FALSE)
  tbl_combined1$text[is.na(tbl_combined1$text)] <- ''
  if (nrow(tbl_combined1) ==0 ){
    next
  }
  # write.xlsx(x = tbl_combined1,  file = save_dir, sheetName = PRS_names[n], append = TRUE)
  
  # if (file.exists(save_dir)){
  #   # 加载现有的Excel文件
  #   wb <- loadWorkbook(save_dir)
  #   # 创建一个新的工作簿（sheet）
  #   addWorksheet(wb, sheetName = PRS_names[n])
  #   writeData(wb, tbl_combined1, sheet = PRS_names[n], colNames = TRUE, rowNames = FALSE)
  #   # 保存工作簿
  #   saveWorkbook(wb, file = save_dir, overwrite = TRUE)
  # }else{
  #   write.xlsx(tbl_combined1, file = save_dir,sheetName = PRS_names[n],colNames = TRUE,rowNames = FALSE)
  # }
  
  p <- ggplot(tbl_combined1, aes(x = Region, y = Trait, fill = percent)) +
    geom_tile(colour = "black", linewidth = 0.2) +
    scale_fill_gradient2(low = '#1A5592', mid = "white", high = "#B83D3D", limits = c(-100, 100)) +
    geom_text(aes(label = text),
              color = "black", 
              size = ifelse(tbl_combined1$bold,1.15, 1),
              vjust = 0.3, hjust = 0.5, 
              fontface = ifelse(tbl_combined1$bold, "bold", "plain"),
              family = "Times New Roman")+ 
    theme_minimal() +
    theme(
      plot.background = element_rect(color ="white", fill = "white"),
      plot.margin = margin(t = 0,
                           r = 0,
                           b = 0,
                           l = 20
      ), 
      panel.border = element_blank(),
      axis.title.x = element_blank(),
      # axis.text.x = element_blank(),
      # axis.ticks.x = element_blank(),
      axis.text.x = element_text(size = 6, color = 'black', angle = 45, hjust = 1, family = "Times New Roman"),
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      # axis.text.y = element_text(size = 6, color = 'black', angle = 0, hjust = 1, family = "Times New Roman"),
      legend.position = 'none'
    ) +
    scale_y_discrete(position = "left") +
    scale_x_discrete(limits = Stand_region_name[c(1,2,34,3:33,35:43)])
  print(p)
  
  dd = 2
  # ggsave(filename = paste(save_path, "color bar.png", sep = '/'),
  #        plot = p, dpi = 500, width = 400, height = 200,units = "mm")
  
  ggsave(filename = paste(save_path, "X_label.pdf", sep = '/'),
         plot = p, dpi = 1000, width = 207, height = 20+dd*length(unique(tbl_combined$Trait)),units = "mm")
  
  
  # ggsave(filename = paste(save_path, paste(PRS_names[n],".pdf",sep = ''), sep = '/'),
  #        plot = p, dpi = 1000, width = 200, height = 3+dd*length(unique(tbl_combined$Trait)),units = "mm")
  # 
  # ggsave(filename = paste(save_path, paste(PRS_names[n],"_legend.pdf",sep = ''), sep = '/'),
  #        plot = p, dpi = 1000, width = 200, height = 3+dd*length(unique(tbl_combined$Trait)),units = "mm")
}



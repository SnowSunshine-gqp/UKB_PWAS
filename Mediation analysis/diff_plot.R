rm(list = ls())
library(readxl)
library(ggplot2)
library(cowplot)
library(patchwork)
Projcet_path = 'Work_path'
save_path = paste(Projcet_path,'Mediate analysis',sep = '/')
Colors = c('Unsig' = "grey",
           'Sig' = 'red')
Threshold = 0.05

Type1_Result = read_excel(paste(Projcet_path, 'Mediate analysis/Mediation_Result_type1.xlsx', sep = '/'))
colnames(Type1_Result)[1] = 'Number'
MDD_Type1_Result = read_excel(paste(Projcet_path, 'Mediate analysis/MDD_Mediation_Result_type1.xlsx', sep = '/'))
colnames(MDD_Type1_Result)[1] = 'Number'
Type1_Result = rbind(Type1_Result, MDD_Type1_Result)

Type2_Result = read_excel(paste(Projcet_path, 'Mediate analysis/Mediation_Result_type2.xlsx', sep = '/'))
colnames(Type2_Result)[1] = 'Number'
MDD_Type2_Result = read_excel(paste(Projcet_path, 'Mediate analysis/MDD_Mediation_Result_type2.xlsx', sep = '/'))
colnames(MDD_Type2_Result)[1] = 'Number'
Type2_Result = rbind(Type2_Result, MDD_Type2_Result)
# Type1_Result$Name = paste(Type1_Result$Disorder, Type1_Result$Mediators, Type1_Result$`Brain region`, sep = '_')
# Type2_Result$Name = paste(Type2_Result$Disorder, Type2_Result$Mediators, Type2_Result$`Brain region`, sep = '_')

PP = list()
for (value in c("percent", 'a effect', 'b effect', 'ab effect', "c' effect", "c effect")){
  p = list()
  for (MD in c("PRS_AD", "PRS_BD", "PRS_ISS", "PRS_PD", "PRS_SCZ", "PRS_MDD")){#  "PRS_MS",
    temp_indx = Type1_Result$Disorder == MD
    if (sum(temp_indx) > 0){
      Temp_type1 = Type1_Result[temp_indx, c('Number', "Disorder", "Mediators", "Brain region", value, "ab Pvalue")]
      colnames(Temp_type1)[5] = 'target'
      Temp_type2 = Type2_Result[temp_indx, c('Number', "Disorder", "Mediators", "Brain region", value, "ab Pvalue")]
      colnames(Temp_type2)[5] = 'target'
      
      Temp_data = merge(Temp_type1, Temp_type2, by = 'Number')
      Temp_data$Significant = ifelse(Temp_data$`ab Pvalue.x` < Threshold & Temp_data$`ab Pvalue.y` < Threshold, 'Sig', 'Unsig')
      
      Temp_Max = max(max(abs(Temp_type1$target)),max(abs(Temp_type2$target)))
      Temp_Max = (Temp_Max %/% 0.001 + 1) * 0.001
      if (value == "percent"){
        Temp_Max = 100
      }
      
      p[[MD]] = ggplot(data = Temp_data)+
        geom_abline(slope = 1, intercept = 0, color = "grey", linewidth = 0.55)+
        geom_hline(yintercept = 0, color = "red", linewidth = 0.55)+
        geom_vline(xintercept = 0, color = "red", linewidth = 0.55)+
        geom_point(aes(x = `target.x`, y = `target.y`, 
                       fill = Significant),
                   shape = 21, size = 1)+
        labs( x="Subgroup 1", y= 'Subgroup 2', title = paste(value, MD, sep = ' of ')) +
        theme_classic() +
        scale_x_continuous(limits = c(-Temp_Max, Temp_Max)) +  # 设置 x 轴范围为 0 到 6
        scale_y_continuous(limits = c(-Temp_Max, Temp_Max)) +
        scale_fill_manual(values = Colors,
                          limits = c('Unsig', 'Sig')) +
        theme(
          axis.title = element_text( size=10),
          axis.line = element_line(color = "black", linewidth=0.4), # 应用于x和y轴的线条
          # axis.line.x = element_blank(), # x轴的线条不显示
          axis.line.y.left = element_line(color = "black", linewidth=0.4), # y轴的线条显示
          axis.line.y.right = element_line(color = "white", linewidth=0),
          # axis.text.x = element_blank(), # x轴的文本标签不显示
          # axis.ticks.x = element_blank(), # x轴的刻度不显示
          axis.text.y = element_text(color = "black", size=10), # y轴左侧的文本标签显示
          axis.ticks.y = element_line(color = "black"), # y轴左侧的刻度显示
          axis.title.y = element_text(angle = 90, vjust = 0.5), # y轴标题的旋转和垂直对齐
          legend.position = 'none',
          # legend.text = element_text(size=12),
          # legend.title = element_text(size=14),
          # legend.key.size = unit(0.3, "inches"),
          # panel.grid.minor = element_blank(),
          # 隐藏右侧的y轴文本标签和刻度
          axis.text.y.right = element_blank(),
          axis.ticks.y.right = element_blank()
        )
      # print(p)
      # ggsave(paste(save_path,paste(MD, 'Mediation_Diff_Plot.pdf', sep = '_'),sep = '/'), p[[MD]], dpi = 500, width = 20, height = 10, units = "in")
    }
  }
  PP[[value]] = p
}

# 使用 cowplot 组合图形
combined_plot = plot_grid(PP$percent$PRS_AD, PP$percent$PRS_BD, PP$percent$PRS_ISS, PP$percent$PRS_PD, PP$percent$PRS_SCZ, PP$percent$PRS_MDD,
                          PP$`a effect`$PRS_AD, PP$`a effect`$PRS_BD, PP$`a effect`$PRS_ISS, PP$`a effect`$PRS_PD, PP$`a effect`$PRS_SCZ, PP$`a effect`$PRS_MDD,
                          PP$`b effect`$PRS_AD, PP$`b effect`$PRS_BD, PP$`b effect`$PRS_ISS, PP$`b effect`$PRS_PD, PP$`b effect`$PRS_SCZ, PP$`b effect`$PRS_MDD,
                          PP$`ab effect`$PRS_AD, PP$`ab effect`$PRS_BD, PP$`ab effect`$PRS_ISS, PP$`ab effect`$PRS_PD, PP$`ab effect`$PRS_SCZ, PP$`ab effect`$PRS_MDD,
                          PP$`c' effect`$PRS_AD, PP$`c' effect`$PRS_BD, PP$`c' effect`$PRS_ISS, PP$`c' effect`$PRS_PD, PP$`c' effect`$PRS_SCZ, PP$`c' effect`$PRS_MDD,
                          PP$`c effect`$PRS_AD, PP$`c effect`$PRS_BD, PP$`c effect`$PRS_ISS, PP$`c effect`$PRS_PD, PP$`c effect`$PRS_SCZ, PP$`c effect`$PRS_MDD,
                          ncol = 6, nrow = 6)

ggsave(paste(save_path, paste('Mediation_Diff_Plot.pdf'), sep = '/'), combined_plot, dpi = 500, width = 20, height = 20, units = "in")


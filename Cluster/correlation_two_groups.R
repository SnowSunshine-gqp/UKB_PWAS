rm(list = ls())
library(ggplot2)
library(data.table)
library(readxl)
Project_path = 'Work_path'
save_path = paste(Project_path,'Cluster',sep = '/')

Group1_tbl <- as.data.frame(read_excel(paste(Project_path,'Cluster/MRI group/Feature_diff.xlsx',sep = '/')))
Group2_tbl <- as.data.frame(read_excel(paste(Project_path,'Cluster/non-MRI group/Feature_diff.xlsx',sep = '/')))

TBL <- data.frame(
  Trait_name = Group1_tbl$Row,
  Group1 = Group1_tbl$`t value`,
  Group2 = Group2_tbl$`t value` 
)

# Calculated correlation coefficient
cor_value <- cor(TBL$Group1, TBL$Group2)

p = ggplot(TBL, aes(x = Group1, y = Group2)) +
  geom_point(size = 4, color = "black") +
  geom_smooth(method = "lm", se = F, color = "red" ,linewidth = 1.5) +
  labs(x = "t value of MRI cohort", y = "t value of non-MRI cohort") +
  theme_bw() +
  theme(
    axis.title.x = element_text(size = 20, color = "black"),
    axis.title.y = element_text(size = 20, color = "black"),
    axis.text.x = element_text(size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
  )+
  annotate("text", x = Inf, y = -Inf, label = paste0("r = ", round(cor_value, 2)), 
           vjust = -1, hjust = 1, size = 10, color = "black")
show(p)

ggsave(paste(save_path,'Group_correlation.png',sep = '/'), p, dpi = 500, width = 180, height = 150, units = "mm")


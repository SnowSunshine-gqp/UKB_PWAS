#require(data.table)
library(ggplot2)
library(ggrepel)
library(ggbreak)
library(readxl)
require(dplyr)
require(tidyr)
require(RColorBrewer)

rm(list=ls())
projcet_path = 'Work_path'
save_path <- paste(projcet_path,'Cluster/MRI group',sep = '/')
setwd(projcet_path)

dfres <- read_excel(paste(projcet_path,'Cluster/MRI group/Feature_diff.xlsx',sep = '/'))
dfres <- dfres[-c(1:5),]
colnames(dfres)[9] = 'Domain'
dfres$bonferroni_p <- p.adjust(dfres$`p value`,method="bonferroni",n=length(dfres$`p value`))
dfres$P <- dfres$`p value`

dfres$plotx=seq(1,3*nrow(dfres)+10,3)[1:nrow(dfres)]

colors <- c('Blood biomarkers' = "#007BFF",
            "Diet" = "#28A745",
            "Early life factors" = "#6F42C1",
            "General health" = "#FF7F00",
            "Lifestyle" = "#FFC107",
            "Local environment" = "#E3342F",
            "Physical measurements" = "#00CED1",
            "Psychosocial" = "#D1BCFE",
            "Socioeconomic" = "#17A2B8")


#thr1<-0.05/241
thr <- 0.05
# 为dfres中的每个行设置一个名为size的变量，初始值为4，当dfres$x小于阈值thr时，将size设置为6  
# dfres$size <- 1.5

dfres$size <- ifelse(abs(dfres$`t value`)>10,5,2)

# dfres$size[dfres$bonferroni_p<thr] <- dfres$Significant_size[dfres$bonferroni_p<thr]


thr_T <- dfres$`t value`[dfres$bonferroni_p<thr]

r_upper=min(thr_T[thr_T>0])
r_lower=max(thr_T[thr_T<0])

X_axis <- dfres %>% group_by(Domain) %>% summarize(center=( max(plotx) +min(plotx) ) / 2 )
X_axis$Category <- unique(dfres$Domain)


x_max <- max(dfres$plotx)
dt <- 10
y_max <-  ceiling(max(dfres$`t value`)  / dt ) * dt
y_min <-  floor(min(dfres$`t value`) / dt) * dt
step_value <- 25

p<-ggplot(dfres, aes(x=plotx, y=`t value`)) + 
  geom_hline(yintercept=r_upper, color='red', linewidth=0.4,linetype="longdash")+
  geom_hline(yintercept=r_lower, color='red', linewidth=0.4,linetype="longdash")+
  geom_hline(yintercept=0, color="black", linewidth=0.55)+
  # geom_hline(yintercept=-log10(thr), color=ss[6], size=0.4,linetype="longdash")+
  geom_point(aes(colour = Domain,y = `t value`),size=dfres$size) + 
  #shape=Correlation_directions
  labs(color="Domain", x="", y=expression('t value')) +
  
  ggrepel::geom_text_repel(data=. %>% mutate(label = ifelse(abs(`t value`) > 25, as.character(dfres$Row), "")), 
                            aes(label=label),
                            colour="black", 
                            segment.colour="black",
                            size=5, 
                            arrow = NULL,
                            max.time = 0.5,
                            # nudge_y = ifelse(dfres$raw_e > 0, 0.003, -0.003) 
                            # + ifelse(dfres$trait_name == 'Townsend deprivation index', 0.015, 0),
                            max.overlaps = getOption("ggrepel.max.overlaps", default = 500),
                            min.segment.length = unit(0.1, "inches"))+
  scale_colour_manual(values = colors, 
                      limits = c('Blood biomarkers','Diet','Early life factors','General health','Lifestyle','Local environment','Physical measurements','Psychosocial','Socioeconomic') )+
  guides(colour = guide_legend(override.aes = list(size = 6))) + # 设置颜色标
  theme_classic() + 
  theme(
    axis.title = element_text(face="bold", size=16),
    axis.line = element_line(color = "black", linewidth=0.4), # 应用于x和y轴的线条
    axis.line.x = element_blank(), # x轴的线条不显示
    axis.line.y.left = element_line(color = "black", linewidth=0.4), # y轴的线条显示
    axis.line.y.right = element_line(color = "white", linewidth=0),
    axis.text.x = element_blank(), # x轴的文本标签不显示
    axis.ticks.x = element_blank(), # x轴的刻度不显示
    axis.text.y = element_text(color = "black", size=10), # y轴左侧的文本标签显示
    axis.ticks.y = element_line(color = "black"), # y轴左侧的刻度显示
    axis.title.y = element_text(angle = 90, vjust = 0.5), # y轴标题的旋转和垂直对齐
    legend.text = element_text(size=12),
    legend.title = element_text(size=14),
    legend.key.size = unit(0.3, "inches"),
    panel.grid.minor = element_blank(),
    # 隐藏右侧的y轴文本标签和刻度
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank()
  )+
  scale_y_continuous(
    breaks = seq(y_min, y_max, by = step_value),  # 设置刻度间隔
    limits = c(y_min, y_max), # 设置纵坐标的范围
  )
print(p)
ggsave(paste(save_path,'Manhattan_map.png',sep = '/'), p, dpi = 500, width = 400, height = 200, units = "mm")


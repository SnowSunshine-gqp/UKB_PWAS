#require(data.table)
library(ggplot2)
library(ggrepel)
library(ggbreak)
require(dplyr)
require(tidyr)
require(RColorBrewer)

rm(list=ls())
projcet_path = 'Work_path'
save_path <- paste(projcet_path,'Cluster/non-MRI group',sep = '/')
setwd(projcet_path)

dfres <- read.csv(paste(projcet_path,'Cluster/non-MRI group/Feature_diff.csv',sep = '/'))
dfres <- dfres[-c(1:5),]
colnames(dfres)[8] = 'Domain'
dfres$bonferroni_p <- p.adjust(dfres$p.value,method="bonferroni",n=length(dfres$p.value))
dfres$P <- dfres$raw_p

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

thr <- 0.05
dfres$size <- ifelse(abs(dfres$t.value)>50,5,2)
thr_T <- dfres$t.value[dfres$bonferroni_p<thr]
r_upper=min(thr_T[thr_T>0])
r_lower=max(thr_T[thr_T<0])

X_axis <- dfres %>% group_by(Domain) %>% summarize(center=( max(plotx) +min(plotx) ) / 2 )
X_axis$Category <- unique(dfres$domain)

x_max <- max(dfres$plotx)
y_max <-  590
y_min <-  -240
step_value <- 50

p<-ggplot(dfres, aes(x=plotx, y=t.value)) + 
  geom_hline(yintercept=r_upper, color='red', size=0.4,linetype="longdash")+
  geom_hline(yintercept=r_lower, color='red', size=0.4,linetype="longdash")+
  geom_hline(yintercept=0, color="black", size=0.55)+
  # geom_hline(yintercept=-log10(thr), color=ss[6], size=0.4,linetype="longdash")+
  geom_point(aes(colour = Domain,y = t.value),size=dfres$size) + 
  #shape=Correlation_directions
  labs(color="Domain", x="", y=expression('t value')) +
  
  ggrepel::geom_text_repel(data=. %>% mutate(label = ifelse(abs(t.value) > 100, as.character(dfres$Row), "")), aes(label=label), 
                            size=4, box.padding = unit(0.3, "lines"),
                            max.overlaps = getOption("ggrepel.max.overlaps", default = 550),
                            min.segment.length = 0)+
  scale_colour_manual(values = colors, 
                      limits = c('Blood biomarkers','Diet','Early life factors','General health','Lifestyle','Local environment','Physical measurements','Psychosocial','Socioeconomic') )+
  theme_classic() + 
  theme(axis.title = element_text(face="bold",size=16),
        axis.line.y = element_line(color = "black",size=0.4),
        axis.line.x = element_blank(),
        axis.text.x = element_blank(), 
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(color = "black",size=10),
        legend.text = element_text(size=12),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.3, "inches"),
        panel.grid.minor=element_blank()
  )+
  scale_y_continuous(
    breaks = seq(y_min, y_max, by = step_value),
    limits = c(y_min, y_max),
  )
print(p)

ggsave(paste(save_path,'Manhattan_map.png',sep = '/'), p, dpi = 500, width = 350, height = 180, units = "mm")

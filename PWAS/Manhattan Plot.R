#require(data.table)
library(ggplot2)
library(ggrepel)
library(ggbreak)
require(dplyr)
require(tidyr)
require(RColorBrewer)

rm(list=ls())
Project_path = 'Work_path'
save_path <- paste(Project_path,'PWAS',sep = '/')
setwd(Project_path)

dfres <- read.csv(paste(Project_path,'PWAS/TotalVolume_Phenotypic_results.csv',sep = '/'))
dfres$bonferroni_p <- p.adjust(dfres$raw_p,method="bonferroni",n=length(dfres$raw_p))
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

#thr1<-0.05/241
thr <- 0.05
dfres$size <- 3
dfres$size <- ifelse(dfres$bonferroni_p  < 0.05,6,dfres$size)


thr_r <- dfres$raw_e[dfres$bonferroni_p<thr]
r_upper=min(thr_r[thr_r>0])
r_lower=max(thr_r[thr_r<0])
X_axis <- dfres %>% group_by(domain) %>% summarize(center=( max(plotx) +min(plotx) ) / 2 )
X_axis$Category <- unique(dfres$Domain)


x_max <- max(dfres$plotx)
y_max <-  0.065
y_min <-  -0.125
step_value <- 0.015

p<-ggplot(dfres, aes(x=plotx, y=raw_e)) + 
  geom_hline(yintercept=r_upper, color='red', linewidth=0.4,linetype="longdash")+
  geom_hline(yintercept=r_lower, color='red', linewidth=0.4,linetype="longdash")+
  geom_hline(yintercept=0, color="black", linewidth=0.55)+
  # geom_hline(yintercept=-log10(thr), color=ss[6], size=0.4,linetype="longdash")+
  geom_point(aes(colour = domain,y = raw_e),size=dfres$size) + 
  #shape=Correlation_directions
  labs(color="Domain", x="", y=expression('Beta')) +
  
  ggrepel::geom_text_repel(data=. %>% mutate(label = ifelse(bonferroni_p < 0.05/182, as.character(dfres$trait_name), "")), 
                           aes(label=label),
                           colour="black", 
                           segment.colour="black",
                           size=4, 
                           box.padding = unit(0.1, "inches"),
                           point.padding = unit(0.1, "inches"),
                           arrow = NULL,
                           max.time = 0.5,
                           max.overlaps = getOption("ggrepel.max.overlaps", default = 20),
                           nudge_y = ifelse(dfres$trait_name == 'Immature reticulocyte fraction', 0.01, 0),
                           nudge_x = ifelse(dfres$trait_name == 'Immature reticulocyte fraction', 1, 0),
                           min.segment.length = unit(0.1, "inches"))+
  scale_colour_manual(values = colors, 
                      limits = c('Blood biomarkers','Diet','Early life factors','General health','Lifestyle','Local environment','Physical measurements','Psychosocial','Socioeconomic') )+
  guides(colour = guide_legend(override.aes = list(size = 6))) + 
  theme_classic() + 
  theme(
    axis.title = element_text(face="bold", size=16),
    axis.line = element_line(color = "black", size=0.4), 
    axis.line.x = element_blank(), 
    axis.line.y.left = element_line(color = "black", size=0.4),
    axis.line.y.right = element_line(color = "white", size=0),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(color = "black", size=10),
    axis.ticks.y = element_line(color = "black"),
    axis.title.y = element_text(angle = 90, vjust = 0.5),
    legend.text = element_text(size=12),
    legend.title = element_text(size=14),
    legend.key.size = unit(0.3, "inches"),
    panel.grid.minor = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank()
  ) +
  scale_y_continuous(
    breaks = seq(y_min, y_max, by = step_value),
    limits = c(y_min, y_max),
  )+
  scale_y_break(c(-0.11, -0.055),
                space = 0.05,
                scales = 10
  )

ggsave(paste(save_path,'Manhattan_map.png',sep = '/'), p, dpi = 500, width = 20, height = 10, units = "in")

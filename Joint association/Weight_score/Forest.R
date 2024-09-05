rm(list=ls())
library(ggplot2)
library(rsvg)
library(forestploter)
library(readxl)
library(grid)
library(tibble) 
library(dplyr)

Projcet_path <-  'Work_path'
dir_path <- paste(Projcet_path,'Joint association/Weight_score/Forest.xlsx',sep = '/')
region_name= c('Total volume','Cortical volume','Subcortical volume')
Diseane_name = c("ACD", "ACS", "AXT", "BP", "MDD", "MS", "PD", "SCZ")
Diseane_name_all <-  c("ACD",
                       "ACS",
                       "AXT",
                       "BP",
                       "MDD",
                       "MS",
                       "PD",
                       "SCZ")
Title_ = c('The composite score of modifiable traits for total GMV',
           'The composite score of modifiable traits for Cortical GMV',
           'The composite score of modifiable traits for Subcortical GMV')

for (n in seq(length(region_name))){
  save_path <- paste(Projcet_path,'Joint association/Weight_score',paste(region_name[n],' Forest.png',sep = ''),sep = '/')
  dt <- read_excel(dir_path,sheet = region_name[n])
  N = 8
  new_dt <- dt
  
  for ( i in 1:N ) {
    new_dt <- add_row(new_dt,
                      Level = Diseane_name_all[i],
                      .before = 4*i-3)
  }
  new_dt$Level[seq(2,nrow(new_dt),4)] = '    Favourable'
  new_dt$Level[seq(3,nrow(new_dt),4)] = '    Intermediate'
  new_dt$Level[seq(4,nrow(new_dt),4)] = '    Unfavourable'
  
  new_dt$`p Value` <- ifelse(new_dt$pvalue < 0.001, "<0.001", sprintf("%.3f",new_dt$pvalue))
  new_dt$`p Value`[seq(1,4*N,4)] = ''
  new_dt$`p Value`[seq(4,4*N,4)] = ''
  new_dt$`Event number`[seq(1,4*N,4)] = ''
  new_dt$' ' <-  paste(rep(" ",20),collapse = " ")
  new_dt$'HR (95% CI)'  <- ifelse(is.na(new_dt$HR),"",sprintf("%.2f (%.2f, %.2f)",new_dt$HR, new_dt$Lower, new_dt$Upper))
  new_dt$'HR (95% CI)'  <- ifelse(new_dt$Level == '    Unfavourable',"1 (reference)",new_dt$'HR (95% CI)')
  
  tm <- forest_theme(base_size = 10,
                     ci_pch = 15,
                     ci_col = 'grey5',
                     footnote_gp = gpar(cex = 0.6, fontface = "italic", col = "black"),
                     refline_gp = gpar(lwd = 1, lty = "dashed", col = "red"))
  p <- forest(new_dt[,c(2,7,10,9,8)],
              est = new_dt$HR,
              lower = new_dt$Lower,
              upper = new_dt$Upper,
              sizes = 0.6,
              ref_line = 1,
              ci_column = 4,
              xlim = c(0,1.1),
              ticks_at = seq(0,1.1,0.25),
              theme = tm)
  p <- edit_plot(p,
                 row = seq(4,4*N,4),
                 col = 4,
                 which = "ci",
                 gp = gpar(col = "red"))
  p <- edit_plot(p, which = "background",
                 gp = gpar(fill = "white"))
  p <- edit_plot(p, 
                 row = seq(1,4*N,4),
                 which = "background",
                 gp = gpar(fill = "grey"))
  p <- insert_text(p,
                   text = Title_[n],
                   col = 1:6,
                   row = 1,
                   part = "header",
                   gp = gpar(fontface = "bold"))
  p <- add_border(p, part = "header", where = "bottom")
  plot(p)
  
  ggsave(filename = save_path, plot = p, dpi = 500, width = 200, height = 250, units = "mm")
}



rm(list = ls())
Project_path = 'Work_path'
# Load packages
library("mice")

File_path = paste(Project_path,'/Data/Population/MRI group/Traits.csv',sep = '/')
Data <- read.csv(File_path)
Data <- subset(Data,select = -c(eid))
sum(is.na(Data)) #

imp <- mice(Data, pred = quickpred(Data, mincor = 0.2, minpuc = 0.1),m = 5,method = "pmm")
imp_Data <- complete(imp)
sum(is.na(imp_Data)) #375

save_path = paste(Project_path,'/Data/Population/MRI group/Imputated MRI group Traits.csv',sep = '/')
write.csv(imp_Data,save_path)

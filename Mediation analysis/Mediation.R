rm(list = ls())
library(data.table)
# library(mediation)
library(bruceR)
library(openxlsx)
Project_path = 'Work_path'
File_path = paste(Project_path,'Mediation analysis/tbl.csv',sep = '/')
df <- as.data.frame(fread(File_path))
colnames(df)

Y.names <- colnames(df[189:232])
X.names<- colnames(df[2:7])
M.names<- colnames(df[c(8:189)])
Y.n = length(Y.names)
X.n = length(X.names)
M.n = length(M.names)

temp_formula = " ~ "
col.names = c('a E','a P','b E','b P',"c' E","c' P","c E","c P","Indirect (ab) E","Indirect (ab) P","Direct (c') E","Direct (c') P","Total (c) E","Total (c) P")
save_path = paste(Project_path,'Mediate analysis/Result',sep = '/')

for (i in 1:X.n ){
  for (j in 1:Y.n ) {
    model.D <- summary(lm(formula = paste(Y.names[j],temp_formula,X.names[i]), data = df))
    tbl <- matrix(nrow = M.n, ncol = 14)
    for (k in 1:M.n ){
      cat(j, '-', k, '\n')
      model.M <- summary(lm(formula = paste(M.names[k],temp_formula,X.names[i]), data = df))
      model.Y <- summary(lm(formula = paste(Y.names[j],temp_formula,X.names[i],'+',M.names[k]), data = df))
      if (model.M$coefficients[X.names[i],4] > 0.05 | model.Y$coefficients[M.names[k],4] > 0.05){
        next()
      }
      temp_A <- PROCESS(df, y = Y.names[j], x = X.names[i],
                        meds = M.names[k],
                        ci="mcmc", nsim=50, seed =1)
      tbl[k,1:2] = model.M$coefficients[X.names[i],c(1,4)]# a
      tbl[k,3:4] = model.Y$coefficients[M.names[k],c(1,4)]# b
      tbl[k,5:6] = model.Y$coefficients[X.names[i],c(1,4)]# c'
      tbl[k,7:8] = model.D$coefficients[X.names[i],c(1,4)]# c
      tbl[k,c(9,11,13)] = temp_A$results[[1]]$mediation$Effect# Indirect (ab) Direct (c')  Total (c)
      tbl[k,c(10,12,14)] = temp_A$results[[1]]$mediation$pval
    }
    A = as.data.frame(tbl,row.names = M.names)
    colnames(A) = col.names
    Temp_path = paste(save_path,X.names[i],sep = '/')
    if (!dir.exists(Temp_path)){
      dir.create(Temp_path)
    }
    if (file.exists(paste(Temp_path,'Mediation.xlsx',sep = '/'))){
      wb <- loadWorkbook(paste(Temp_path,'Mediation.xlsx',sep = '/'))
      addWorksheet(wb, sheetName = Y.names[j])
      writeData(wb, A, sheet = Y.names[j], colNames = TRUE, rowNames = TRUE)
      saveWorkbook(wb, file = paste(Temp_path,'Mediation.xlsx',sep = '/'), overwrite = TRUE)
    }else{
      write.xlsx(A, file = paste(Temp_path,'Mediation.xlsx',sep = '/'),sheetName = Y.names[j],colNames = TRUE,rowNames = TRUE)
    }
  }
}

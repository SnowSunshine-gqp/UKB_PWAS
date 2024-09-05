rm(list = ls())
library(data.table)
library(mediation)
library(bruceR)
library(openxlsx)
Projcet_path = 'Work_path'
File_path = paste(Projcet_path,'Mediation analysis/MDD_tbl.csv',sep = '/')
df <- as.data.frame(fread(File_path))
colnames(df)[2] = 'PRS_MDD' 
colnames(df)

Y.names <- colnames(df[185:227]) # 227:269
X.names<- colnames(df)[2] # c(4,22,25,27,32)
Modifiable.names<- colnames(df[c(3:184)])
Y.n = length(Y.names)
X.n = length(X.names)

temp_formula = " ~ "
col.names = c('a E','a P','b E','b P',"c' E","c' P","c E","c P","Indirect (ab) E","Indirect (ab) P","Direct (c') E","Direct (c') P","Total (c) E","Total (c) P")
save_path = paste(Projcet_path,'Mediation analysis/Significant Traits/Result',sep = '/')

for (i in 1:X.n ){
  M <- as.data.frame(fread(paste(Projcet_path,'Mediation analysis/Result',X.names[i],'Pass_traits.csv',sep = '/')))
  M.names <- Modifiable.names[M$V1]
  M.n = length(M.names)
  tbl_a <- matrix(nrow = 2, ncol = M.n)
  
  tbl_b_E <- matrix(nrow = Y.n, ncol = M.n)
  tbl_b_P <- matrix(nrow = Y.n, ncol = M.n)
  
  tbl_ab_E <- matrix(nrow = Y.n, ncol = M.n)
  tbl_ab_P <- matrix(nrow = Y.n, ncol = M.n)
  
  tbl_c_E <- matrix(nrow = Y.n, ncol = M.n)
  tbl_c_P <- matrix(nrow = Y.n, ncol = M.n)
  
  tbl_cc_E <- matrix(nrow = Y.n, ncol = M.n)
  tbl_cc_P <- matrix(nrow = Y.n, ncol = M.n)
  for (j in 1 : M.n){
    model.M <- summary(lm(formula = paste(M.names[j],temp_formula,X.names[i]), data = df))
    tbl_a[1:2,j] = model.M$coefficients[X.names[i],c(1,4)]# a
    for (k in 1:Y.n ) {
      model.D <- summary(lm(formula = paste(Y.names[k],temp_formula,X.names[i]), data = df))
      model.Y <- summary(lm(formula = paste(Y.names[k],temp_formula,X.names[i],'+',M.names[j]), data = df))
      temp_A <- PROCESS(df, y = Y.names[k], x = X.names[i],
                        meds = M.names[j],
                        ci="mcmc", nsim=1000, seed =1)
      
      tbl_b_E[k,j] = model.Y$coefficients[M.names[j],1]# b
      tbl_b_P[k,j] = model.Y$coefficients[M.names[j],4]# b
      
      tbl_c_E[k,j] = model.Y$coefficients[X.names[i],1]# c'
      tbl_c_P[k,j] = model.Y$coefficients[X.names[i],4]# c'
      
      tbl_ab_E[k,j] = temp_A$results[[1]]$mediation$Effect[1]# ab
      tbl_ab_P[k,j] = temp_A$results[[1]]$mediation$pval[1]# ab
      
      tbl_cc_E[k,j] = temp_A$results[[1]]$mediation$Effect[2]# c'
      tbl_cc_P[k,j] = temp_A$results[[1]]$mediation$pval[2]# c'
      
      tbl_c_E[k,j] = temp_A$results[[1]]$mediation$Effect[3]# c'
      tbl_c_P[k,j] = temp_A$results[[1]]$mediation$pval[3]# c'
    }
  }
  tbl_a = as.data.frame(tbl_a,row.names = c("Estimate","P value"))
  colnames(tbl_a) <- M.names
  
  tbl_b_E <- as.data.frame(tbl_b_E,row.names = Y.names)
  tbl_b_P <- as.data.frame(tbl_b_P,row.names = Y.names)
  colnames(tbl_b_E) <- M.names
  colnames(tbl_b_P) <- M.names
  
  tbl_ab_E <- as.data.frame(tbl_ab_E,row.names = Y.names)
  tbl_ab_P <- as.data.frame(tbl_ab_P,row.names = Y.names)
  colnames(tbl_ab_E) <- M.names
  colnames(tbl_ab_P) <- M.names
  
  tbl_c_E <- as.data.frame(tbl_c_E,row.names = Y.names)
  tbl_c_P <- as.data.frame(tbl_c_P,row.names = Y.names)
  colnames(tbl_c_E) <- M.names
  colnames(tbl_c_P) <- M.names
  
  tbl_cc_E <- as.data.frame(tbl_cc_E,row.names = Y.names)
  tbl_cc_P <- as.data.frame(tbl_cc_P,row.names = Y.names)
  colnames(tbl_cc_E) <- M.names
  colnames(tbl_cc_P) <- M.names
  
  Temp_path = paste(save_path,X.names[i],sep = '/')
  if (!dir.exists(Temp_path)){
    dir.create(Temp_path)
  }
  xlsx_path = paste(Temp_path,'Mediation.xlsx',sep = '/')
  write.xlsx(tbl_a,xlsx_path, sheetName = "a", colNames = TRUE, rowNames = TRUE)
  if (file.exists(xlsx_path)){
    # 加载现有的Excel文件
    wb <- loadWorkbook(xlsx_path)
    
    addWorksheet(wb, sheetName = "b Effect")
    writeData(wb, tbl_b_E, sheet = "b Effect", colNames = TRUE, rowNames = TRUE)
    addWorksheet(wb, sheetName = "b Pvalue")
    writeData(wb, tbl_b_P, sheet = "b Pvalue", colNames = TRUE, rowNames = TRUE)
    
    addWorksheet(wb, sheetName = "c Effect")
    writeData(wb, tbl_c_E, sheet = "c Effect", colNames = TRUE, rowNames = TRUE)
    addWorksheet(wb, sheetName = "c Pvalue")
    writeData(wb, tbl_c_P, sheet = "c Pvalue", colNames = TRUE, rowNames = TRUE)
    
    addWorksheet(wb, sheetName = "cc Effect")
    writeData(wb, tbl_cc_E, sheet = "cc Effect", colNames = TRUE, rowNames = TRUE)
    addWorksheet(wb, sheetName = "cc Pvalue")
    writeData(wb, tbl_cc_P, sheet = "cc Pvalue", colNames = TRUE, rowNames = TRUE)
    
    addWorksheet(wb, sheetName = "ab Effect")
    writeData(wb, tbl_ab_E, sheet = "ab Effect", colNames = TRUE, rowNames = TRUE)
    addWorksheet(wb, sheetName = "ab Pvalue")
    writeData(wb, tbl_ab_P, sheet = "ab Pvalue", colNames = TRUE, rowNames = TRUE)
    
    # 保存工作簿
    saveWorkbook(wb, file = paste(Temp_path,'Mediation.xlsx',sep = '/'), overwrite = TRUE)
  }
}

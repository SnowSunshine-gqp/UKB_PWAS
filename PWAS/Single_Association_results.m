clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/Population/MRI group');
cw_path = fullfile(Project_path,'PWAS');
save_path = fullfile(Project_path,'PWAS');
% Import data
load(fullfile(dir_path,'MRI group info imputate.mat'),'Covariates_MRI','DKT_baseline','Modifiable_MRI','Modifiable_info_MRI');
load(fullfile(cw_path,'Covariates/Association_results.mat'),'Standard_region_info');
% define names of brain regions and traits
region_name = DKT_baseline.Properties.VariableNames(2:end);
region_n = length(region_name);
Factors_name = Modifiable_MRI.Properties.VariableNames(2:end);
Factors_n = length(Factors_name);
% define variables to store
P_value = nan(region_n,Factors_n);
T_value = nan(region_n,Factors_n);
Estimate = nan(region_n,Factors_n);
Lower = nan(region_n,Factors_n);
Upper = nan(region_n,Factors_n);

for i = 1 : region_n
    Temp_image0 = DKT_baseline.(region_name{i});
    Temp_image0 = (Temp_image0 - Standard_region_info.Mean(i) ) ./ Standard_region_info.Std(i);
    for j = 1 : Factors_n
        disp([num2str(i),'-',num2str(j)]);
        Temp_Factor = Modifiable_MRI.(Factors_name{j});
        Factor_indx = ~isnan(Temp_Factor);
        if strcmp(Modifiable_info_MRI.ValueType(j),"Continue") % 连续变量进行标准化
            Temp_Factor(Factor_indx) = zscore(Temp_Factor(Factor_indx));
        end
        Temp_image = Temp_image0(Factor_indx);
        Temp_Factor = Temp_Factor(Factor_indx);
        Temp_Cov = Covariates_MRI(Factor_indx,:);
        Temp_Cov.Factor = Temp_Factor;
        Temp_Cov.Volume = Temp_image;
        formual = 'Volume ~ age + sex + new_Ethnic + Initial_site + TIV + Imaging_site + First_Image_interval + Factor';
        Temp_lme = fitlme(Temp_Cov,formual);
        [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,'Factor','stable');
        P_value(i,j) = Temp_lme.Coefficients.pValue(Temp_indx);
        T_value(i,j) = Temp_lme.Coefficients.tStat(Temp_indx);
        Estimate(i,j) = Temp_lme.Coefficients.Estimate(Temp_indx);
        Lower(i,j) = Temp_lme.Coefficients.Lower(Temp_indx);
        Upper(i,j) = Temp_lme.Coefficients.Upper(Temp_indx);
    end
end
P_value = array2table(P_value,'RowNames',region_name,'VariableNames',Factors_name);
T_value = array2table(T_value,'RowNames',region_name,'VariableNames',Factors_name);
Estimate = array2table(Estimate,'RowNames',region_name,'VariableNames',Factors_name);
Lower = array2table(Lower,'RowNames',region_name,'VariableNames',Factors_name);
Upper = array2table(Upper,'RowNames',region_name,'VariableNames',Factors_name);

save(fullfile(save_path,'Single_Association_results.mat'),...
    'P_value','T_value','Estimate','Lower','Upper');


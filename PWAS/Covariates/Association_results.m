clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/Population/MRI group');
save_path = fullfile(Project_path,'PWAS/Covariates');
% import data
load(fullfile(dir_path,'MRI group info imputate.mat'),'DKT_baseline','Covariates_MRI');
% brain region
region_name = DKT_baseline.Properties.VariableNames(2:end)';
region_n = length(region_name);

interested_info = {'age','sex','new_Ethnic_Asian','new_Ethnic_Black','new_Ethnic_Other'};
% define variables to store 
P_value = nan(region_n,length(interested_info));
T_value = P_value;
Estimate = P_value;
Standard_region_info = zeros(region_n,2);
for i = 1 : region_n
    Temp_image0 = DKT_baseline.(region_name{i});
    [Temp_image,Standard_region_info(i,1),Standard_region_info(i,2) ]= zscore(Temp_image0);
    Temp_Cov = Covariates_MRI;
    Temp_Cov.Volume = Temp_image;
    formual = 'Volume ~ age + sex + new_Ethnic + Initial_site + TIV + Imaging_site + First_Image_interval';
    Temp_lme = fitlme(Temp_Cov,formual);
    % store results
    [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,interested_info,'stable');
    P_value(i,:) = Temp_lme.Coefficients.pValue(Temp_indx)';
    T_value(i,:) = Temp_lme.Coefficients.tStat(Temp_indx)';
    Estimate(i,:) = Temp_lme.Coefficients.Estimate(Temp_indx)';
    disp(i)
end
P_value = array2table(P_value,'RowNames',region_name,'VariableNames',interested_info);
T_value = array2table(T_value,'RowNames',region_name,'VariableNames',interested_info);
Estimate = array2table(Estimate,'RowNames',region_name,'VariableNames',interested_info);
Standard_region_info = array2table(Standard_region_info,'RowNames',region_name,'VariableNames',{'Mean','Std'});
% save results
save(fullfile(save_path,'Association_results.mat'),'P_value','T_value','Estimate','Standard_region_info');



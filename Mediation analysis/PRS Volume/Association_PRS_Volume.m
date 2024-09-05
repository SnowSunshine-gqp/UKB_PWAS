clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Mediation analysis/PRS Volume');
% import data
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'DKT_baseline','Covariates_MRI');
PRS_Data = readtable(fullfile(dir_path,'brain disease PRS data.csv'));
PRS_name = readtable(fullfile(dir_path,'brain disease PRS.xlsx'));
PRS_name_ = strrep(PRS_name.Description,'Standard PRS for ','');
PRS_Data = renamevars(PRS_Data,PRS_Data.Properties.VariableNames(2:end),PRS_name_);
% match eid
[~,ia,ib] = intersect(DKT_baseline.eid,PRS_Data.eid);
Image_Data = DKT_baseline(ia,:);
Covariates = Covariates_MRI(ia,:);
PRS_Data = PRS_Data(ib,:);
% define names
region_name = Image_Data.Properties.VariableNames(2:end)';
region_n = length(region_name);
PRS_name = PRS_Data.Properties.VariableNames(2:end)';
PRS_n = length(PRS_name);

[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates(:,2:8),{'new_Ethnic','Initial_site','Imaging_site'});
First_dummy_indx(1) = 8;
Dummy_Table(:,First_dummy_indx) = [];

Image_rm_cov = zscore(matrix_covariate_regress(table2array(Image_Data(:,2:end)), table2array(Dummy_Table)));
Image_Baseline_rm_cov = array2table([Image_Data.eid,Image_rm_cov],'VariableNames',Image_Data.Properties.VariableNames);
save(fullfile(save_path,'Image_Baseline_rm_cov.mat'),'Image_Baseline_rm_cov');

% define variables to store
P_value = nan(region_n,PRS_n);
T_value = P_value;
Estimate = P_value;
for i = 1 : region_n
    Temp_image0 = Image_rm_cov(:,i);
    for j = 1 : PRS_n
        disp([num2str(i),'-',num2str(j)]);
        Temp_Factor = PRS_Data.(PRS_name{j});
        Factor_indx = ~isnan(Temp_Factor);
        
        Temp_image = Temp_image0(Factor_indx);
        Temp_Factor = Temp_Factor(Factor_indx);
        Temp_Cov = table();
        Temp_Cov.Factor = Temp_Factor;
        Temp_Cov.Volume = Temp_image;
        formual = 'Volume ~ Factor';
        Temp_lme = fitlme(Temp_Cov,formual);
        [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,'Factor');
        P_value(i,j) = Temp_lme.Coefficients.pValue(Temp_indx);
        T_value(i,j) = Temp_lme.Coefficients.tStat(Temp_indx);
        Estimate(i,j) = Temp_lme.Coefficients.Estimate(Temp_indx);
    end
end
%% MDD
MDD = readtable(fullfile(Project_path,'Data/PRS/Total_MDD.csv'));
[c,ia,ib] = intersect(MDD.eid,Image_Baseline_rm_cov.eid);
MDD = MDD(ia,:);
DKT_baseline_MDD = Image_Baseline_rm_cov(ib,:);
for i = 1 : region_n
    Factor_indx = ~isnan(MDD.score);
    Temp_Factor = MDD.score(Factor_indx);
    Temp_image = DKT_baseline_MDD.(region_name{i})(Factor_indx);
    Temp_Cov = table();
    Temp_Cov.Factor = Temp_Factor;
    Temp_Cov.Volume = Temp_image;
    formual = 'Volume ~ Factor';
    Temp_lme = fitlme(Temp_Cov,formual);
    [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,'Factor');
    P_value(i,PRS_n+1) = Temp_lme.Coefficients.pValue(Temp_indx);
    T_value(i,PRS_n+1) = Temp_lme.Coefficients.tStat(Temp_indx);
    Estimate(i,PRS_n+1) = Temp_lme.Coefficients.Estimate(Temp_indx);
end
P_value = array2table(P_value,'RowNames',region_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
T_value = array2table(T_value,'RowNames',region_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
Estimate = array2table(Estimate,'RowNames',region_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
save(fullfile(save_path,'Association_PRS_Volume.mat'),'P_value','T_value','Estimate');


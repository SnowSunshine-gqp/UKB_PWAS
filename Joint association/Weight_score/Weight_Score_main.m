%% run this section after the multiple imputation by chained equations approach in R
clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
Save_path = fullfile(Project_path,'Joint association/Weight_score');
Threshold_up = 2/3 * 100;
Threshold_low = 1/3 * 100;
% import data
load(fullfile(Project_path,'Data/Population/nonMRI group/nonMRI group info.mat'));

Modifiable_nonMRI = readtable(fullfile(Project_path,'Data/Population/nonMRI group/Imputated_Modi_nonMRI.csv'));
Modifiable_nonMRI = renamevars(Modifiable_nonMRI,'Var1','eid');
Modifiable_nonMRI.eid = Covariates_nonMRI.eid;
Modifiable_nonMRI.Properties.VariableNames(2:end) = Modifiable_info_nonMRI.Name;
nan_indx = find(sum(isnan(table2array(Modifiable_nonMRI(:,2:end))),2)); % length(nan_indx) 9267
Modifiable_nonMRI(nan_indx,:) = [];
Covariates_nonMRI(nan_indx,:) = [];
% save(fullfile(Save_path,'nonMRI group info imputate.mat'),'Covariates_nonMRI','Modifiable_nonMRI','Modifiable_info_nonMRI');
%% MRI group
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'));
Region_name = ["Total volume" "Cortical volume" "Subcortical volume"];
for n = 1 : length(Region_name)
    temp_Region_name = Region_name(n);% "Total volume"/"Cortical volume"/"Subcortical volume"
    
    Covariates = Covariates_MRI(:,{'age','sex','new_Ethnic','TIV','Imaging_site','Initial_site','First_Image_interval'});
    [Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates,{'new_Ethnic','Imaging_site','Initial_site'});
    First_dummy_indx(1) = 8;
    Dummy_Table(:,First_dummy_indx) = [];
    Y = zscore(matrix_covariate_regress(DKT_baseline.(temp_Region_name), [ones(length(Covariates_MRI.eid),1),table2array(Dummy_Table)]));
    X = table2array(Modifiable_MRI(:,2:end));
    [XL,YL,XS,YS,BETA,PCTVAR,MSE,stats] = plsregress(X,Y);
    
    Weight_Score = table();
    Weight_Score.eid = Modifiable_nonMRI.eid;
    Weight_Score.score = zscore([ones(length(Modifiable_nonMRI.eid),1),table2array(Modifiable_nonMRI(:,2:end))] * BETA);
    
    Up = prctile(Weight_Score.score,Threshold_up);
    Low = prctile(Weight_Score.score,Threshold_low);
    
    Weight_Score.Intermediate = Weight_Score.score > Low & Weight_Score.score <= Up;
    Weight_Score.Favourable = Weight_Score.score > Up;
    writetable(Weight_Score,fullfile(Save_path,strcat(temp_Region_name,' Weight Score.csv')));
end


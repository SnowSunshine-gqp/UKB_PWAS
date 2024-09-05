clear,clc
Project_path = 'Work_path';
cw_path = fullfile(Project_path,'Data');
save_path = fullfile(Project_path,'Data/Population/MRI group');
region_name = readtable(fullfile(Project_path,'Data/MRI/Stand_region_name.csv'));
region_name = region_name.x;

% import data
load(fullfile(cw_path,'Covariates/UKB Covariates.mat'));
Disease_id = readmatrix(fullfile(cw_path,'Diseases/exclude eid.csv'));
load(fullfile(cw_path,'MRI/DKT_total.mat'));
load(fullfile(cw_path,'Modifiable Traits/Variables.mat'));

% missing data on common covariates;
missing_age_indx = isnan(Covariates.age);
missing_sex_indx = isnan(Covariates.sex);
missing_Ethnic_indx = strcmp(Covariates.new_Ethnic,"");
missing_Initial_site_indx = strcmp(Covariates.Initial_site,"");
indx = missing_age_indx | missing_sex_indx | missing_Ethnic_indx | missing_Initial_site_indx;
Covariates(indx,:) = [];

% Matching participants' eid
[~,ia,ib] = intersect(DKT_baseline.eid,Covariates.eid);
DKT_baseline = DKT_baseline(ia,:);
DKT_Follow = DKT_Follow(ia,:);
Covariates_MRI = Covariates(ib,:); % finally get 43088 participant

Covariates_nonMRI = Covariates;
Covariates_nonMRI(ib,:) = [];
%% MRI Group
% exclusion of participants with conditions that confound brain atrophy
[~,ia] = intersect(Covariates_MRI.eid,Disease_id);
DKT_baseline(ia,:) = [];
DKT_Follow(ia,:) = [];
Covariates_MRI(ia,:) = [];% 37254

% Matching with Modifiable triats in MRI group
[~,ia,ib] = intersect(Covariates_MRI.eid,Modifiable.eid);
DKT_baseline = DKT_baseline(ia,:);
DKT_Follow = DKT_Follow(ia,:);
Covariates_MRI = Covariates_MRI(ia,:);
Modifiable_MRI = Modifiable(ib,:);% 37254

% Traits with more than 15% missing samples were deleted
Threshold = 0.15;
Threshold_indx = sum(isnan(table2array(Modifiable_MRI)),1) > Threshold * size(Modifiable_MRI,1);
% disp(Modifiable.Properties.VariableNames(Threshold_indx)'); 
% 4 delete traits: SHBG\Direct bilirubin\Breastfed as a baby\Neuroticism
Modifiable_MRI(:,Threshold_indx)= [];
Threshold_indx(1) = [];
Modifiable_info_MRI = Modifiable_info;
Modifiable_info_MRI(Threshold_indx,:)= [];

% Samples with more than 15% missing traits were deleted
Threshold_indx = sum(isnan(table2array(Modifiable_MRI(:,2:end))),2) > Threshold * (size(Modifiable_MRI,2) - 1);% sum(Threshold_indx) 1635
DKT_baseline(Threshold_indx,:)= [];
DKT_Follow(Threshold_indx,:)= [];
Covariates_MRI(Threshold_indx,:)= [];
Modifiable_MRI(Threshold_indx,:)= [];% 35570

DKT_baseline.Properties.VariableNames(2:end) = region_name;
DKT_Follow.Properties.VariableNames(2:end) = region_name;
writetable(Modifiable_MRI,fullfile(save_path,'Traits.csv'));
save(fullfile(save_path,'MRI group info.mat'),'DKT_baseline','DKT_Follow','Covariates_MRI','Modifiable_MRI','Modifiable_info_MRI');
%% Non-MRI Group
% Matching with Modifiable triats in non-MRI group
[~,ia,ib] = intersect(Covariates_nonMRI.eid,Modifiable.eid);
Covariates_nonMRI = Covariates_nonMRI(ia,:);
Modifiable_nonMRI = Modifiable(ib,:);% 458422
save_path = fullfile(Project_path,'Data/Population/nonMRI group');
% 4 delete traits: SHBG\Direct bilirubin\Breastfed as a baby\Neuroticism
Modifiable_info_nonMRI = Modifiable_info_MRI;
Modifiable_nonMRI.('SHBG') = [];
Modifiable_nonMRI.('Direct bilirubin') = [];
Modifiable_nonMRI.('Breastfed as a baby') = [];
Modifiable_nonMRI.('Neuroticism') = [];

writetable(Modifiable_nonMRI,fullfile(save_path,'Traits.csv'));
save(fullfile(save_path,'nonMRI group info.mat'),'Covariates_nonMRI','Modifiable_nonMRI','Modifiable_info_nonMRI');

%% run this section after the multiple imputation by chained equations approach in R
clear,clc
Project_path = 'Work_path';
save_path = fullfile(Project_path,'Data/Population/MRI group');
% import data
load(fullfile(save_path,'MRI group info.mat'),'DKT_baseline','DKT_Follow','Covariates_MRI','Modifiable_info_MRI');

Modifiable_MRI = readtable(fullfile(save_path,'Imputated MRI group Traits.csv'));
Modifiable_MRI = renamevars(Modifiable_MRI,'Var1','eid');
Modifiable_MRI.eid = DKT_baseline.eid;
Modifiable_MRI.Properties.VariableNames(2:end) = Modifiable_info_MRI.Name;

nan_indx = find(sum(isnan(table2array(Modifiable_MRI(:,2:end))),2)); % length(nan_indx) 375

Modifiable_MRI(nan_indx,:) = [];
Covariates_MRI(nan_indx,:) = [];
DKT_baseline(nan_indx,:) = [];
DKT_Follow(nan_indx,:) = [];

save(fullfile(save_path,'MRI group info imputate.mat'),'DKT_baseline','DKT_Follow','Covariates_MRI','Modifiable_MRI','Modifiable_info_MRI');
% % Follow-up
% Follow_indx = isnan(DKT_Follow.("Total volume"));
% 
% Covariates_MRI(Follow_indx,:) = [];
% Modifiable_MRI(Follow_indx,:) = [];
% DKT_baseline(Follow_indx,:) = [];
% DKT_Follow(Follow_indx,:) = [];
% save(fullfile(save_path,'Group1 info Follow.mat'),'DKT_baseline','DKT_Follow','Covariates_G1','Modifiable_G1','Modifiable_info_G1');

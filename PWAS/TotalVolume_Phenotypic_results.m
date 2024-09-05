clear,clc
Project_path = 'Work_path';
save_path = fullfile(Project_path,'PWAS');
% import data
load(fullfile(save_path,'Single_Association_results.mat'),'P_value','Estimate','Lower','Upper');
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info.mat'),'Modifiable_info_MRI');
% define names
Factor_name = P_value.Properties.VariableNames';
Region_name = P_value.Row;
%% 
Region_indx = 1; % select region name: TotalVolume
E = table2array(Estimate(Region_indx,:))';
P = table2array(P_value(Region_indx,:))';
Low = table2array(Lower(Region_indx,:))';
Up = table2array(Upper(Region_indx,:))';
Threshold = 0.05;

TBL = table();
TBL.trait_name = Factor_name;
TBL.raw_p = P;
TBL.raw_e = E;
TBL.domain = Modifiable_info_MRI.Domain;
writetable(TBL,fullfile(save_path,'TotalVolume_Phenotypic_results.csv'));



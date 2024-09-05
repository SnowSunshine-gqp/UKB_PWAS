clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Mediation analysis');
% import data
load(fullfile(Project_path,'Mediation analysis/PRS Volume/Image_Baseline_rm_cov.mat'));
load(fullfile(Project_path,'Mediation analysis/PRS Modifiable/Modifiable_rm_cov.mat'));
MDD = readtable(fullfile(dir_path,'Total_MDD.csv'));

[~,ia,ib] = intersect(MDD.eid,Image_Baseline_rm_cov.eid);
MDD = MDD(ia,:);
Image_Baseline_rm_cov = Image_Baseline_rm_cov(ib,:);
Modifiable_rm_cov = Modifiable_rm_cov(ib,:);% sum(Image_Baseline_rm_cov.eid == Modifiable_rm_cov.eid)

Region_name = Image_Baseline_rm_cov.Properties.VariableNames(2:end)';
Region_name = strrep(Region_name,' ','_');
Image_Baseline_rm_cov.Properties.VariableNames(2:end) = Region_name;

Modifiable_name = Modifiable_rm_cov.Properties.VariableNames(2:end);
Modifiable_name = strrep(Modifiable_name,' ','_');
Modifiable_name = strrep(Modifiable_name,'-','_');
Modifiable_name = strrep(Modifiable_name,'(','');
Modifiable_name = strrep(Modifiable_name,')','');
Modifiable_name = strrep(Modifiable_name,"'",'');
Modifiable_name = strrep(Modifiable_name,",",'');
Modifiable_name = strrep(Modifiable_name,"/",'');
Modifiable_rm_cov.Properties.VariableNames(2:end) = Modifiable_name;

TBL = [MDD,Modifiable_rm_cov(:,2:end),Image_Baseline_rm_cov(:,2:end)];
writetable(TBL,fullfile(save_path,'MDD_tbl.csv'));

clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Mediation analysis');
% import data
load(fullfile(Project_path,'Mediation analysis/PRS Modifiable/Modifiable_rm_cov.mat'));
load(fullfile(Project_path,'Mediation analysis/PRS Volume/Image_Baseline_rm_cov.mat'));

PRS_Data = readtable(fullfile(dir_path,'brain disease PRS data.csv'));
PRS_name = readtable(fullfile(dir_path,'brain disease PRS.xlsx'));
PRS_name_ = strrep(PRS_name.Description,'Standard PRS for ','');

PRS_n = length(PRS_name_);
PRS_NewName = [];
for n = 1 : PRS_n
    temp = strsplit(PRS_name_{n},'(');
    PRS_NewName{n} = ['PRS_',strrep(temp{2},')','')];
end
PRS_Data = renamevars(PRS_Data,PRS_Data.Properties.VariableNames(2:end),PRS_NewName);

[~,ia,ib] = intersect(PRS_Data.eid,Image_Baseline_rm_cov.eid);
PRS_Data = PRS_Data(ia,:);
Image_Baseline_rm_cov = Image_Baseline_rm_cov(ib,:);

[~,ia,ib] = intersect(PRS_Data.eid,Modifiable_rm_cov.eid);
PRS_Data = PRS_Data(ia,:);
Image_Baseline_rm_cov = Image_Baseline_rm_cov(ia,:);
Modifiable_rm_cov = Modifiable_rm_cov(ib,:);

Region_name = Image_Baseline_rm_cov.Properties.VariableNames(2:end);
Region_name = strrep(Region_name,' ','_');
Image_Baseline_rm_cov.Properties.VariableNames(2:end) = Region_name;

Modifiable_name = Modifiable_rm_cov.Properties.VariableNames(2:end)';
Modifiable_name = strrep(Modifiable_name,' ','_');
Modifiable_name = strrep(Modifiable_name,'-','_');
Modifiable_name = strrep(Modifiable_name,'(','');
Modifiable_name = strrep(Modifiable_name,')','');
Modifiable_name = strrep(Modifiable_name,"'",'');
Modifiable_name = strrep(Modifiable_name,",",'');
Modifiable_name = strrep(Modifiable_name,"/",'');
Modifiable_rm_cov.Properties.VariableNames(2:end) = Modifiable_name;

TBL = [PRS_Data,Modifiable_rm_cov(:,2:end),Image_Baseline_rm_cov(:,2:end)];
writetable(TBL,fullfile(save_path,'tbl.csv'));

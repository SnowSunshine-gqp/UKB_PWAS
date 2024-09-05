clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Cluster/MRI group');
% import data
load(fullfile(Project_path,'Cluster/MRI group/Cluster_idx.mat'));
PRS_Data = readtable(fullfile(dir_path,'brain disease PRS data.csv'));
PRS_name = readtable(fullfile(dir_path,'brain disease PRS.xlsx'));
PRS_name_ = strrep(PRS_name.Description,'Standard PRS for ','');
PRS_Data.Properties.VariableNames(2:end) = PRS_name_;

[~,ia] = intersect(PRS_Data.eid,type1_eid);
PRS1 = PRS_Data(ia,:);

[~,ia] = intersect(PRS_Data.eid,type2_eid);
PRS2 = PRS_Data(ia,:);

[h,p,ci,stats] = ttest2(table2array(PRS1(:,2:end)),table2array(PRS2(:,2:end)));
TBL = table();
TBL.name = PRS_name_;
TBL.subtype1_mean = mean(table2array(PRS1(:,2:end)),1,'omitnan')';
TBL.subtype1_std = std(table2array(PRS1(:,2:end)),1,'omitnan')';
TBL.subtype2_mean = mean(table2array(PRS2(:,2:end)),1,'omitnan')';
TBL.subtype2_std = std(table2array(PRS2(:,2:end)),1,'omitnan')';
TBL.tValue = stats.tstat';
TBL.pValue = p';

MDD = readtable(fullfile(Project_path,'Data/PRS/Total_MDD.csv'));
[~,ia,ib] = intersect(MDD.eid,type1_eid);
MDD_type1 = MDD.score(ia);
[~,ia,ib] = intersect(MDD.eid,type2_eid);
MDD_type2 = MDD.score(ia);
[h,p,ci,stats] = ttest2(MDD_type1,MDD_type2);
MDD_info = {'major depressive disorder (MDD)',mean(MDD_type1),std(MDD_type1),mean(MDD_type2),std(MDD_type2),stats.tstat,p};
TBL = [TBL;MDD_info];
TBL.FDR_pValue = mafdr(TBL.pValue,'BHFDR','true');

save(fullfile(save_path,'PRS_diff.mat'),'TBL');
writetable(TBL,fullfile(save_path,'PRS_diff.xlsx'),'WriteRowNames',1);


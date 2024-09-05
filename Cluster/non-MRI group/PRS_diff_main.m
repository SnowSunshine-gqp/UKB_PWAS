clear,clc
Project_path = 'Work_path';
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Cluster/non-MRI group');
% import data
UKB_eid = readtable(fullfile(Project_path,'Cluster/non-MRI group/UKB_label.csv'));
PRS_Data = readtable(fullfile(dir_path,'brain disease PRS data.csv'));
PRS_name = readtable(fullfile(dir_path,'brain disease PRS.xlsx'));
PRS_name_ = strrep(PRS_name.Description,'Standard PRS for ','');
PRS_Data.Properties.VariableNames(2:end) = PRS_name_;

type1_eid = UKB_eid.eid(UKB_eid.label == 0);
type2_eid = UKB_eid.eid(UKB_eid.label == 1);

[~,ia] = intersect(PRS_Data.eid,type1_eid);
PRS1 = PRS_Data(ia,:);

[~,ia] = intersect(PRS_Data.eid,type2_eid);
PRS2 = PRS_Data(ia,:);

[h,p,ci,stats] = ttest2(table2array(PRS1(:,2:end)),table2array(PRS2(:,2:end)));
TBL = table();
TBL.name = PRS_Data.Properties.VariableNames(2:end)';
TBL.subtype1_mean = mean(table2array(PRS1(:,2:end)),1,'omitnan')';
TBL.subtype1_std = std(table2array(PRS1(:,2:end)),1,'omitnan')';
TBL.subtype2_mean = mean(table2array(PRS2(:,2:end)),1,'omitnan')';
TBL.subtype2_std = std(table2array(PRS2(:,2:end)),1,'omitnan')';
TBL.tValue = stats.tstat';
TBL.pValue = p';
% TBL.FDR_pValue = mafdr(p','BHFDR','true');

MDD = readtable(fullfile(Project_path,'Data/PRS/Total_MDD.csv'));
[~,ia,ib] = intersect(MDD.eid,type1_eid);
MDD_type1 = MDD.score(ia);
[~,ia,ib] = intersect(MDD.eid,type2_eid);
MDD_type2 = MDD.score(ia);

[h,p,ci,stats] = ttest2(MDD_type1,MDD_type2);
MDD_info = {'major depressive disorder (MDD)',mean(MDD_type1),std(MDD_type1),mean(MDD_type2),std(MDD_type2),stats.tstat,p};
TBL = [TBL;MDD_info];

save(fullfile(save_path,'PRS_diff.mat'),'TBL');
writetable(TBL,fullfile(save_path,'PRS_diff.xlsx'));




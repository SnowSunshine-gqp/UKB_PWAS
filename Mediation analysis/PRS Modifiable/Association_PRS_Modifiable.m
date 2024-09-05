clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Mediation analysis/PRS Modifiable');
% import data
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Covariates_MRI','Modifiable_MRI','Modifiable_info_MRI');
PRS_Data = readtable(fullfile(dir_path,'brain disease PRS data.csv'));
PRS_name = readtable(fullfile(dir_path,'brain disease PRS.xlsx'));
PRS_name_ = strrep(PRS_name.Description,'Standard PRS for ','');
PRS_Data = renamevars(PRS_Data,PRS_Data.Properties.VariableNames(2:end),PRS_name_);
% match eid
[~,ia,ib] = intersect(Modifiable_MRI.eid,PRS_Data.eid);
Modifiable = Modifiable_MRI(ia,:);
Covariates = Covariates_MRI(ia,:);
PRS_Data = PRS_Data(ib,:);
% define names
Modifiable_name = Modifiable.Properties.VariableNames(2:end)';
Modifiable_n = length(Modifiable_name);
PRS_name = PRS_Data.Properties.VariableNames(2:end)';
PRS_n = length(PRS_name);

[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates(:,2:5),{'new_Ethnic','Initial_site'});
First_dummy_indx(1) = 6;
Dummy_Table(:,First_dummy_indx) = [];

Continues_indx = strcmp(Modifiable_info_MRI.ValueType,"Continue");
Modifiable_rm_cov = table2array(Modifiable);
Modifiable_rm_cov(:,[false;Continues_indx]) = zscore(matrix_covariate_regress(table2array(Modifiable(:,[false;Continues_indx])), table2array(Dummy_Table)));
Modifiable_rm_cov = array2table(Modifiable_rm_cov,'VariableNames',Modifiable.Properties.VariableNames);

save(fullfile(save_path,'Modifiable_rm_cov.mat'),'Modifiable_rm_cov');
% define variables to store
P_value = nan(Modifiable_n,PRS_n);
T_value = P_value;
Estimate = P_value;
for i = 1 : Modifiable_n
    Temp_Modifiable = Modifiable_rm_cov.(Modifiable_name{i});
    for j = 1 : PRS_n
        disp([num2str(i),'-',num2str(j)]);
        Temp_PRS = PRS_Data.(PRS_name{j});
        Factor_indx = ~isnan(Temp_PRS);

        Temp_Cov = table();
        Temp_Cov.PRS = Temp_PRS(Factor_indx);
        Temp_Cov.Modifiable = Temp_Modifiable(Factor_indx);
        formual = 'Modifiable ~ PRS';
        Temp_lme = fitlme(Temp_Cov,formual);
        [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,'PRS');
        P_value(i,j) = Temp_lme.Coefficients.pValue(Temp_indx);
        T_value(i,j) = Temp_lme.Coefficients.tStat(Temp_indx);
        Estimate(i,j) = Temp_lme.Coefficients.Estimate(Temp_indx);
    end
end
%% MDD
MDD = readtable(fullfile(Project_path,'Data/PRS/Total_MDD.csv'));
[c,ia,ib] = intersect(MDD.eid,Modifiable_rm_cov.eid);
MDD = MDD(ia,:);
Modifiable_rm_cov_MDD = Modifiable_rm_cov(ib,:);
for i = 1 : Modifiable_n
    Temp_Modifiable = Modifiable_rm_cov_MDD.(Modifiable_name{i});
    Temp_PRS = MDD.score;
    Factor_indx = ~isnan(Temp_PRS);
    
    Temp_Cov = table();
    Temp_Cov.PRS = Temp_PRS(Factor_indx);
    Temp_Cov.Modifiable = Temp_Modifiable(Factor_indx);
    formual = 'Modifiable ~ PRS';
    Temp_lme = fitlme(Temp_Cov,formual);
    [~,Temp_indx] = intersect(Temp_lme.CoefficientNames,'PRS');
    P_value(i,PRS_n+1) = Temp_lme.Coefficients.pValue(Temp_indx);
    T_value(i,PRS_n+1) = Temp_lme.Coefficients.tStat(Temp_indx);
    Estimate(i,PRS_n+1) = Temp_lme.Coefficients.Estimate(Temp_indx);
end
P_value = array2table(P_value,'RowNames',Modifiable_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
T_value = array2table(T_value,'RowNames',Modifiable_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
Estimate = array2table(Estimate,'RowNames',Modifiable_name,'VariableNames',[PRS_name;"major depressive disorder (MDD)"]);
save(fullfile(save_path,'Association_PRS_Modifiable.mat'),'P_value','T_value','Estimate');


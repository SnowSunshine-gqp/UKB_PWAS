clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
save_path = fullfile(Project_path,'Cluster/non-MRI group');
% import data
load(fullfile(Project_path,'PWAS/Single_Association_results.mat'));
load(fullfile(Project_path,'Data/Population/nonMRI group/nonMRI group info.mat'));
% Explore the differences between subgroups
UKB_label = readtable(fullfile(save_path,'UKB_label.csv'));
Covariates = Covariates_nonMRI(:,{'eid','age','sex','new_Ethnic'});
[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates,{'sex','new_Ethnic'});%
First_dummy_indx(2) = 8;
Dummy_Table(:,First_dummy_indx) = [];
Dummy_Table.Properties.VariableNames(2:6) = {'Age','Sex','Ethnic_Asian','Ethnic_Black','Ethnic_Other'};%
Feature = [Dummy_Table,Modifiable_nonMRI(:,2:end)];

temp = [];
UKB_type1_eid = UKB_label.eid(UKB_label.label == 0);
[~,ia1] = intersect(Feature.eid,UKB_type1_eid); 
temp{1} = Feature(ia1,:);
UKB_type2_eid = UKB_label.eid(UKB_label.label == 1);
[~,ia2] = intersect(Feature.eid,UKB_type2_eid); 
temp{2} = Feature(ia2,:);

Feature_name = Feature.Properties.VariableNames(2:end);
Feature_n = length(Feature_name);
Feature_diff = nan(Feature_n,6);
for n = 1 : Feature_n
    temp_1 = temp{1}.(Feature_name{n});
    indx1 = ~isnan(temp_1);
    
    if length(unique(temp_1(indx1))) == 2
        Feature_diff(n,1) = sum(temp_1,'omitnan');
        Feature_diff(n,2) = sum(temp_1,'omitnan') ./ sum(indx1);
    else
        Feature_diff(n,1) = mean(temp_1,'omitnan');
        Feature_diff(n,2) = std(temp_1,'omitnan');
    end
    temp_2 = temp{2}.(Feature_name{n});
    indx2 = ~isnan(temp_2);
    
    if length(unique(temp_2(indx2))) == 2
        Feature_diff(n,3) = sum(temp_2,'omitnan');
        Feature_diff(n,4) = sum(temp_2,'omitnan') ./ sum(indx2);
    else
        Feature_diff(n,3) = mean(temp_2,'omitnan');
        Feature_diff(n,4) = std(temp_2,'omitnan');
    end
    [h,p,ci,stats] = ttest2(temp_1,temp_2);
    Feature_diff(n,5) = stats.tstat;
    Feature_diff(n,6) = p;
end
Feature_diff = array2table(Feature_diff,'VariableNames',{'mean/count 1','std/percent 1','mean/count 2','std/percent 2','t value','p value'},'RowNames',Feature_name);
Feature_diff.domain = [repmat("Covariates",5,1);Modifiable_info_nonMRI.Domain];
save(fullfile(save_path,'Feature_diff.mat'),'Feature_diff');
writetable(Feature_diff,fullfile(save_path,'Feature_diff.xlsx'),'WriteRowNames',1);
% save(fullfile(save_path,'UKB_Class_eid.mat'),'UKB_type1_eid','UKB_type2_eid');

clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
save_path = fullfile(Project_path,'Cluster/non-MRI group/Survive analysis/Diseases_KM_collect');
Disease_path = fullfile(Project_path,'Data/Diseases/Survive analysis');
UKB_subtype_label = readtable(fullfile(Project_path,'Cluster/non-MRI group/UKB_label.csv'));
type1_eid = UKB_subtype_label.eid(UKB_subtype_label.label == 0);
type2_eid = UKB_subtype_label.eid(UKB_subtype_label.label == 1);
% import data
load(fullfile(Project_path,'Data/Covariates/Field_53_54.mat'));
load(fullfile(Project_path,'Data/Population/nonMRI group/nonMRI group info.mat'),'Covariates_nonMRI');
% match eid
[~,ia,ib] = intersect(Covariates_nonMRI.eid,selected_data_table.eid);
Covariates = Covariates_nonMRI(ia,:);
[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates,{'new_Ethnic'});

Recruit = selected_data_table(ib,:);
End_date = datetime('2024-01-30');

Disease_dir = struct2table(dir(Disease_path));
Disease_dir(1:3,:) = [];
Disease_n = length(Disease_dir.name);
for n = 1 : Disease_n
    load(fullfile(Disease_dir.folder{n},Disease_dir.name{n},'Disease_event.mat'));
    % match eid
    [~,ia,ib] = intersect(Covariates.eid,Disease_event.eid);
    
    temp_tbl = table();
    temp_tbl.eid = Covariates.eid(ia);
    temp_tbl.sex = Covariates.sex(ia);
    temp_tbl.age = Covariates.age(ia);
    temp_tbl.Asian = Dummy_Table.new_Ethnic_Asian(ia);
    temp_tbl.Black = Dummy_Table.new_Ethnic_Black(ia);
    temp_tbl.Other = Dummy_Table.new_Ethnic_Other(ia);
    
    temp_tbl.Date_Recruit = Recruit.x53_0_0(ia);
    temp_tbl.Date_Event = Disease_event.Event_Date(ib);
    temp_tbl.Duration = days(temp_tbl.Date_Event - temp_tbl.Date_Recruit)./ 365;
    temp_tbl.Event_label = ~isnan(temp_tbl.Duration);
    temp_tbl.Duration(~temp_tbl.Event_label) = days(End_date - temp_tbl.Date_Recruit(~temp_tbl.Event_label))./ 365;
    
    % Group1_label
    temp_tbl.Group_label = zeros(length(temp_tbl.eid),1);
    [~,ia] = intersect(temp_tbl.eid,type1_eid);
    temp_tbl.Group_label(ia) = 1;
    % stat from the baseline
    temp_tbl(temp_tbl.Duration < 0,:) = [];
    writetable(temp_tbl,fullfile(save_path,[Disease_dir.name{n},'_KM.csv']));
    disp(strcat(Disease_dir.name{n},': N = ',num2str(sum(temp_tbl.Event_label)),...
        '    Group1 n =',num2str(sum(temp_tbl.Group_label == 1 & temp_tbl.Event_label == 1)),...
        '    Group2 n =',num2str(sum(temp_tbl.Group_label == 0 & temp_tbl.Event_label == 1))));
end

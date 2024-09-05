clear,clc
Project_path = 'Work_path';
dir_path= fullfile(Project_path,'Mediation analysis/Result');
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Modifiable_info_MRI');
A = struct2table(dir(fullfile(dir_path,'PRS_*')));
PRS_name = A.name;
PRS_n = length(PRS_name);
Threshold = 0.05/182;
% Specify the worksheet and scope
opts = spreadsheetImportOptions("NumVariables", 14);
opts.DataRange = "B2:O182";
opts.VariableNamesRange = "B1:O1";
opts.RowNamesRange = "A2:A182";
% Specify the column name and type
opts.VariableNames = [ "aE", "aP", "bE", "bP", "cE", "cP", "cE1", "cP1", "IndirectabE", "IndirectabP", "DirectcE", "DirectcP", "TotalcE", "TotalcP"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

for n = 1 : PRS_n
    temp_save_path = fullfile(A.folder{n},A.name{n});
    temp_file_name = fullfile(temp_save_path,'Mediation.xlsx');
    temp_sheetname = sheetnames(temp_file_name);
    temp_file_n = length(temp_sheetname);
    temp_data = cell(temp_file_n,1);
    a_P_value = [];
    a_E_value = [];
    b_P_value = [];
    b_E_value = [];
    ab_P_value = [];
    ab_E_value = [];
    c_P_value = [];
    c_E_value = [];
    for j = 1 : temp_file_n
        opts.Sheet = temp_sheetname{j};
        temp_D = readtable(temp_file_name,opts);
        a_E_value(:,j) = temp_D.aE;
        a_P_value(:,j) = temp_D.aP;
        b_E_value(:,j) = temp_D.bE;
        b_P_value(:,j) = temp_D.bP;
        c_E_value(:,j) = temp_D.DirectcE;
        c_P_value(:,j) = temp_D.DirectcP;
        ab_E_value(:,j) = temp_D.IndirectabE;
        ab_P_value(:,j) = temp_D.IndirectabP;
        temp_data{j} = temp_D;
        disp(j)
    end
    reletive_power = abs(ab_E_value ./ c_E_value);
    Modifiable_name = temp_D.Row;
    Modifiable_indx = sum(a_P_value < Threshold & b_P_value < Threshold,2) >= 1;
    Power_indx = mean(reletive_power,2,'omitnan') > 0.1;% sum(Power_indx)
    Modifiable_indx = find(Modifiable_indx & Power_indx);
    Pass_Modifiable_name = Modifiable_info_MRI.Name(Modifiable_indx);
    Pass_Modifiable_n = length(Pass_Modifiable_name);
    
    writematrix(Modifiable_indx,fullfile(temp_save_path,'FDR_Pass_traits.csv'));
end




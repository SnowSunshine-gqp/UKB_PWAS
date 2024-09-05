clear,clc
Project_path = 'Work_path';
save_path = fullfile(Project_path,'PWAS/Supple.xlsx');
load(fullfile(Project_path,'PWAS/Single_Association_results.mat'));

Region_name = Estimate.Row;
Region_n = length(Region_name);

E = table2array(Estimate);
Low = table2array(Lower);
Up = table2array(Upper);
T = table2array(T_value);
P = table2array(P_value);

Trait_name = Estimate.Properties.VariableNames';
for n = 1 : Region_n
    
    temp_Data = table();
    temp_Data.TraitName = Trait_name;
    temp_Data.Beta = E(n,:)';
    temp_Data.Lower = Low(n,:)';
    temp_Data.Upper = Up(n,:)';
    temp_Data.Tvalue = T(n,:)';
    temp_Data.Pvalue = P(n,:)';
    
    writetable(temp_Data,save_path,'sheet',Region_name{n});
end

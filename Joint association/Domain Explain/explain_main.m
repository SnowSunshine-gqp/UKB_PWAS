clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
save_path = fullfile(Project_path,'Joint association/Domain Explain');
% import data
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Covariates_MRI','DKT_baseline','Modifiable_MRI','Modifiable_info_MRI');
load(fullfile(Project_path,'PWAS/Single_Association_results.mat'),'P_value');
% category variables are converted to dummy variables
Covariates_ = Covariates_MRI(:,{'eid','age','sex','new_Ethnic','TIV','Initial_site','Imaging_site','First_Image_interval'});
[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates_,{'sex','new_Ethnic','Initial_site','Imaging_site'});
First_dummy_indx(2) = 10;
Dummy_Table(:,First_dummy_indx) = [];
Cov = table2array(Dummy_Table);

% define names
region_name = DKT_baseline.Properties.VariableNames(2:end);
region_n = length(region_name);
Feature_name = Modifiable_MRI.Properties.VariableNames(2:end);
Feature_n = length(Feature_name);

Continues_indx = strcmp(Modifiable_info_MRI.ValueType,'Continue');
% remove the covariates
DKT_baseline_rm = matrix_covariate_regress(table2array(DKT_baseline(:,2:end)), [ones(length(DKT_baseline.eid),1),Cov(:,2:end)]);
Modifiable_MRI_rm = table2array(Modifiable_MRI(:,2:end));
Modifiable_MRI_rm(:,Continues_indx) = matrix_covariate_regress(table2array(Modifiable_MRI(:,[false;Continues_indx])), [ones(length(Modifiable_MRI.eid),1),Cov(:,[2,5:28])]);
% standardize data
DKT_baseline_rm_std = zscore(DKT_baseline_rm);
Modifiable_MRI_rm_std = zscore(Modifiable_MRI_rm);

X_All = Modifiable_MRI_rm_std;
Domain_name = unique(Modifiable_info_MRI.Domain);
Domain_n = length(Domain_name);
Factors_indx = cell(Domain_n,1);
for i = 1 : Domain_n
    Factors_indx{i} = strcmp(Modifiable_info_MRI.Domain,Domain_name{i});
end

R2_store = zeros(region_n,10);
for i = 1 : region_n
    disp(i);
    Y = DKT_baseline_rm_std(:,i);
    
    SST = sum((Y - mean(Y)).^2);
    [~,~,~,~,~,~,~,stats_All] = plsregress(X_All,Y);
    SSE_All = sum(stats_All.Yresiduals.^2);
    R2_store(i,1) = 1 - SSE_All/SST;
    
    for n = 1 : length(Domain_name)
        X_temp = Modifiable_MRI_rm_std(:,Factors_indx{n});
        
        [~,~,~,~,~,~,~,stats_temp] = plsregress(X_temp,Y);
        SSE_temp = sum(stats_temp.Yresiduals.^2);
        R2_store(i,n+1) = 1 - SSE_temp/SST;
    end
end
R2_store_tbl = array2table(R2_store,'RowNames',region_name,'VariableNames',['Full model';Domain_name]);
save(fullfile(save_path,'PLS_R2.mat'),'R2_store_tbl');
%% Plot BrainMap
load(fullfile(save_path,'PLS_R2.mat'));
load(fullfile(Project_path,'Data/MRI/fsa5_name.mat'));
region_name = R2_store_tbl.Properties.RowNames;
region_n = length(region_name);

[~,ia,ib] = intersect(region_CS_name_fsa5.Stand_RegionName,region_name,'stable');
CortSurf = zeros(length(region_CS_name_fsa5.fsa5_Name),1);
CortSurf(ia) = 100*R2_store_tbl.("Full model")(ib);
% CortSurf(abs(CortSurf) < T_threshold ) = 0;
CortSurf = [CortSurf;CortSurf];
partial_r_cs_fsa5 = parcel_to_surface(CortSurf, 'aparc_fsa5');% Map parcellated data to the surface

% subcortex volume
[~,ia,ib] = intersect(region_SV_name_fsa5.Stand_RegionName,region_name,'stable');
SubVol = zeros(length(region_SV_name_fsa5.fsa5_Name),1);
SubVol(ia) = 100*R2_store_tbl.("Full model")(ib);
% SubVol(abs(SubVol) < T_threshold ) = 0;
SubVol = [SubVol;SubVol];
% plot
plot_scale = max(abs([CortSurf;SubVol]));
plot_scale = [0,plot_scale];
figure();
plot_cortical(partial_r_cs_fsa5, 'surface_name', 'fsa5', 'color_range',plot_scale,'cmap', 'Reds');
% colorbar('Orientation', 'vertical');
savefig(fullfile(save_path,'Cortical surface ER.fig'));
close 
figure();
plot_subcortical(SubVol, 'color_range', plot_scale,'cmap', 'Reds');
savefig(fullfile(save_path,'Subcortex volume ER.fig'))
close

%% Draw a bar chart
% color design
RGB_list = [154 214 231;199 224 180;225 164 161;209 195 224;206 113 112;255 237 150;123 211 204;255 202 232;243 110 75]./255;
region_name = readtable(fullfile(Project_path,'Data/MRI/Stand_region_name.csv'));
region_name = region_name.x;
REorder = [1:2,34,3:33,35:43];
region_name_ = region_name(REorder);
R2_store_tbl_ = R2_store_tbl(REorder,:);
% plot
figure();
hold on
Data = 100*table2array(R2_store_tbl_(:,2:end));
[~,I] = sort(mean(Data),'descend');
Data_sort = Data(:,I);
Data_position = cumsum([zeros(43,1),Data_sort],2);
for i = region_n : -1 : 1
    b = barh(region_n+1-i,Data_sort(i,:),'stacked');
    for n = 1 : Domain_n
        b(n).FaceColor = RGB_list(n,:);
        A = num2str(Data_sort(i,n),'%.2f');
        if Data_sort(i,n) > 0.4
            text( mean(Data_position(i,n:n+1)), b(n).XData, A,'HorizontalAlignment','center','FontSize',10,'Color',[0,0,0]);
        end
    end
end
Domain_name(1) = "Blood biomarkers";
legend(Domain_name(I))
gcf
hold off
grid on
yticks(1 : region_n);
yticklabels(region_name_(region_n : -1 : 1));
xlabel('R^2 (%)')
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontSize', 12);
set(gca, 'YTickLabel', get(gca, 'YTickLabel'), 'FontSize', 12);

set(gcf,'Position',[0 0 550 1000])
xticks(0:100)
xlim([0,6.5])
savefig(fullfile(save_path,'ER.fig'));

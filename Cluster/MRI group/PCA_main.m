clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
save_path = fullfile(Project_path,'Cluster/MRI group');
% import data
load(fullfile(Project_path,'PWAS/Single_Association_results.mat'));
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Covariates_MRI','DKT_baseline','Modifiable_MRI','Modifiable_info_MRI');
% define names
region_name = DKT_baseline.Properties.VariableNames(2:end);
region_n = length(region_name);
Factors_name = Modifiable_MRI.Properties.VariableNames(2:end);
Factors_n = length(Factors_name);

Threshold = 0.05/182; %set threshold of p-value
P_value_ = table2array(P_value);
region_indx = 1; % limit to total volume
Sig_feature = P_value_(region_indx,:) < Threshold;% sum(Sig_feature)
X = Modifiable_MRI(:,[false,Sig_feature]);
X_ = table2array(X);
Continue_feature_idx = strcmp(Modifiable_info_MRI.ValueType(Sig_feature),"Continue");

%% Remove the effects of covariates
Covariates_ = Covariates_MRI(:,{'eid','age','sex','new_Ethnic'});
[Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Covariates_,{'sex','new_Ethnic'});%
First_dummy_indx(2) = 8;
Dummy_Table(:,First_dummy_indx) = [];
Dummy_Table.Properties.VariableNames(2:6) = {'Age','Sex','Ethnic_Asian','Ethnic_Black','Ethnic_Other'};%
Feature = [Dummy_Table,Modifiable_MRI(:,2:end)];

[result_data] = matrix_covariate_regress(X_(:,Continue_feature_idx), [ones(size(Dummy_Table,1),1),table2array(Dummy_Table(:,2:end))]);% 需要加上一列常数项
result_data_zscore = zscore(result_data);
X_feature_ = X_;
X_feature_(:,Continue_feature_idx) = result_data_zscore;
X_feature_(:,~Continue_feature_idx) = zscore(X_feature_(:,~Continue_feature_idx));
X_feature = array2table(X_feature_,'VariableNames',X.Properties.VariableNames);
%% PCA
[coeff,score,latent,tsquared,explained,mu] = pca(X_feature_);
plot(cumsum(explained))

Threshold = 75;
PC_n = find(cumsum(explained) >= Threshold,1);
Z = linkage(score(:,1:PC_n),'ward');

H = dendrogram(Z,'ColorThreshold', 'default');
set(H, 'LineWidth', 2);

savefig(fullfile(save_path,'ward_dendrogram.fig'));

Cluster_idx = cluster(Z,'maxclust',2);
type1_eid = Feature.eid(Cluster_idx == 1);
type2_eid = Feature.eid(Cluster_idx == 2);
save(fullfile(save_path,'Cluster_idx.mat'),'type1_eid','type2_eid');
writematrix(type1_eid,fullfile(save_path,'type1_eid.csv'));
writematrix(type2_eid,fullfile(save_path,'type2_eid.csv'));

%% Search for optimal classification
X = score(:,1:PC_n);
eva1 = evalclusters(X,'kmeans','CalinskiHarabasz','KList',1:10);
p1 = plot(eva1);
p1.LineWidth = 2;
xlabel('Number of Clusters')
ylabel('CalinskiHarabasz Values')
savefig('./CalinskiHarabasz.fig');

eva2 = evalclusters(X,'kmeans','DaviesBouldin','KList',1:10);
p2 = plot(eva2);
p2.LineWidth = 2;
xlabel('Number of Clusters')
ylabel('DaviesBouldin Values')
savefig('./DaviesBouldin.fig');

eva3 = evalclusters(X,'kmeans','silhouette','KList',1:10);
p3 = plot(eva3);
p3.LineWidth = 2;
xlabel('Number of Clusters')
ylabel('silhouette Values')
savefig('./silhouette.fig');
%% Explore the differences between subgroups
group_n = length(unique(Cluster_idx));
temp = [];
for i = 1 : group_n
   temp{i} =  Feature(Cluster_idx == i,:);
end

Feature_name = Feature.Properties.VariableNames(2:end);
Feature_n = length(Feature_name);
Feature_diff = nan(Feature_n,6);
for n = 1 : Feature_n
    temp_1 = temp{1}.(Feature_name{n});
    Feature_diff(n,1) = mean(temp_1);
    if length(unique(temp_1)) == 2
        Feature_diff(n,1) = sum(temp_1);
        Feature_diff(n,2) = sum(temp_1) ./ length(temp_1);
    else
        Feature_diff(n,2) = std(temp_1);
    end
    
    temp_2 = temp{2}.(Feature_name{n});
    Feature_diff(n,3) = mean(temp_2);
    if length(unique(temp_2)) == 2
        Feature_diff(n,3) = sum(temp_2);
        Feature_diff(n,4) = sum(temp_2) ./ length(temp_2);
    else
        Feature_diff(n,4) = std(temp_2);
    end
    
    [~,p,~,stats] = ttest2(temp_1,temp_2);
    Feature_diff(n,5) = stats.tstat;
    Feature_diff(n,6) = p;

end
Feature_diff = array2table(Feature_diff,'VariableNames',...
    {'mean 1','std 1','mean 2','std 2','t value','p value'},...
    'RowNames',Feature_name);

[~,ia] = intersect(Feature_diff.Row,X_feature.Properties.VariableNames);
Feature_diff.Cluter_Feature = false(length(Feature_diff.Row),1);
Feature_diff.Cluter_Feature(ia) = true;
Feature_diff.domain = [repmat("Covariates",5,1);Modifiable_info_MRI.Domain];
save(fullfile(save_path,'Feature_diff.mat'),'Feature_diff');
writetable(Feature_diff,fullfile(save_path,'Feature_diff.xlsx'),'WriteRowNames',1);
%% Compare differences in brain volume
DKT_group = [];
for j = 1 : group_n
    DKT_group{j} = DKT_baseline(Cluster_idx == j,:);
end
Region_diff = zeros(region_n,6);

for n = 1 : region_n
    temp_1 = DKT_group{1}.(region_name{n});
    temp_2 = DKT_group{2}.(region_name{n});
    Region_diff(n,1) = mean(temp_1,1,'omitnan');
    Region_diff(n,2) = std(temp_1,1,'omitnan');
    Region_diff(n,3) = mean(temp_2,1,'omitnan');
    Region_diff(n,4) = std(temp_2,1,'omitnan');
    [h,p,ci,stats] = ttest2(temp_1,temp_2);
    Region_diff(n,5) = stats.tstat;
    Region_diff(n,6) = p;
end
col_name = {'mean 1','std 1','mean 2','std 2','t value','p value'};
Region_diff = array2table(Region_diff,'RowNames',region_name,'VariableNames',col_name);
% Region_diff.FDR_p = mafdr(Region_diff.("p value"),'BHFDR',true);
save(fullfile(save_path,'Region_diff.mat'),'Region_diff');
writetable(Region_diff,fullfile(save_path,'Region_diff.xlsx'),'WriteRowNames',1);
%% plot brain map
load(fullfile(save_path,'Region_diff.mat'),'Region_diff');
load(fullfile(Project_path,'Data/MRI/fsa5_name.mat'));

T_threshold = 0.05/43;
% cortex surface
[~,ia,ib] = intersect(region_CS_name_fsa5.Stand_RegionName,Region_diff.Row,'stable');
CortSurf_T = zeros(length(region_CS_name_fsa5.fsa5_Name),1);
CortSurf_P = zeros(length(region_CS_name_fsa5.fsa5_Name),1);
CortSurf_T(ia) = Region_diff.("t value")(ib);
CortSurf_P(ia) = Region_diff.("p value")(ib);

CortSurf_T(CortSurf_P > T_threshold ) = 0;
CortSurf_T = [CortSurf_T;CortSurf_T];
partial_r_cs_fsa5 = parcel_to_surface(CortSurf_T, 'aparc_fsa5');% Map parcellated data to the surface

% subcortex volume
[~,ia,ib] = intersect(region_SV_name_fsa5.Stand_RegionName,Region_diff.Row,'stable');

SubVol_T = Region_diff.("t value")(ib);
SubVol_P = Region_diff.("p value")(ib);

SubVol_T(SubVol_P > T_threshold ) = 0;
SubVol_T = [SubVol_T;SubVol_T];

% plot
plot_scale = max(abs([CortSurf_T;SubVol_T]));
plot_scale = [-plot_scale,plot_scale];
figure();
plot_cortical(partial_r_cs_fsa5, 'surface_name', 'fsa5', 'color_range',plot_scale);
savefig(fullfile(save_path,'Cortical surface T value.fig'));
close
figure();
plot_subcortical(SubVol_T, 'color_range', plot_scale);
savefig(fullfile(save_path,'Subcortex volume T value.fig'))
% cbar = colorbar('Orientation', 'vertical');
cb = colorbar('TickLength', 0);
set(cb,'Position',[0.05 0.45 0.03 0.3]);% To change size
close



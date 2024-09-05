clear,clc
Project_path = 'Work_path';
cw_path = fullfile(Project_path,'PWAS/Covariates');
save_path = fullfile(Project_path,'PWAS/Covariates/Figures');

load(fullfile(cw_path,'Association_results.mat'),'P_value','Estimate');
interested_info = {'Age','Sex','Asian','Black','Other'};
Threshold = 0.05;
%%
sum_stats = load_summary_stats('22q');
CS = sum_stats.CortSurf_case_vs_controls;
SV = sum_stats.SubVol_case_vs_controls;

region_name_result = Estimate.Row;

%% cortex surface
region_CS_name = CS.Structure;
region_CS_name_ = strrep(region_CS_name,'L_','');
region_CS_name_ = strrep(region_CS_name_,'R_','');
region_CS_name_fsa5 = unique(region_CS_name_);

[~,ia,ib] = intersect(region_CS_name_fsa5,region_name_result);
Plot_info_cortex = zeros(length(region_CS_name_fsa5),length(interested_info));

Plot_info_cortex(ia,:) = table2array(Estimate(ib,:));
Pass_indx = table2array(P_value(ib,:)) > Threshold;
Plot_info_cortex(Pass_indx) = 0;

Plot_info_cortex = [Plot_info_cortex;Plot_info_cortex];
% Map parcellated data to the surface
cortex = cell(length(interested_info),1);
for i = 1 : length(interested_info)
    label = interested_info{i};
    cortex{i} = parcel_to_surface(Plot_info_cortex(:,i), 'aparc_fsa5');
end
%% subcortex volume
region_SV_name_fsa5 = {'accumbens','amygdala','caudate','hippocampus','Pallidum','putamen','thalamus','Lateral-Ventricle'};

[~,ia,ib] = intersect(region_SV_name_fsa5,region_name_result,'stable');
Plot_info_subcortex = table2array(Estimate(ib,:));
Pass_indx = table2array(P_value(ib,:)) > Threshold;
Plot_info_subcortex(Pass_indx) = 0;
Plot_info_subcortex = [Plot_info_subcortex;Plot_info_subcortex];

%% plot
scale = zeros(length(interested_info),1);
for i = 1 : length(interested_info)
   scale(i) = max(abs(min([cortex{i}';Plot_info_subcortex(:,i)])),abs(max([cortex{i}';Plot_info_subcortex(:,i)])));
end
scale_ethnic = max(scale(3:5));


for i = 1 : length(interested_info)
    
    if i > 2
        plot_scale = [-scale_ethnic,scale_ethnic];
    else
        plot_scale = [-scale(i),scale(i)];
    end
    figure();
    plot_cortical(cortex{i}', 'surface_name', 'fsa5', 'color_range', plot_scale, 'cmap', 'RdBu_r');
    savefig(fullfile(save_path,[interested_info{i},' Cortical surface.fig']));
    close all
    figure();
    plot_subcortical(Plot_info_subcortex(:,i), 'color_range', plot_scale, 'cmap', 'RdBu_r');
    savefig(fullfile(save_path,[interested_info{i},' Subcortex volume.fig']))
    close all
end




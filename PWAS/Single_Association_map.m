clear,clc
Project_path = 'Work_path';
save_path = fullfile(Project_path,'PWAS');
addpath(fullfile(Project_path,'Packages'));
load(fullfile(save_path,'Single_Association_results.mat'),'P_value','Estimate');
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Modifiable_info_MRI');

color_2 = ["A6CEE3" "1F78B4" "B2DF8A" "33A02C","FB9A99","E31A1C"];
color_number_2 = HEX2RGB(color_2)/255;
region_name = readtable(fullfile(Project_path,'Data/MRI/Stand_region_name.csv'));
region_name = region_name.x;

region_n = length(region_name);
Factor_name = P_value.Properties.VariableNames';
Factor_n = length(Factor_name);
% set threshold of p-value
threshold_0 = 0.05/182;
threshold_1 = 0.05/182^2;
threshold_2 = 0.05/182^3;

P = table2array(P_value);
%% plot figure
region_order = [1:2,34,3:33,35:43];
region_name = region_name(region_order);

P = P(region_order,:);

indx = logical(sum(P < threshold_0,1) >= 5);
Factor_name_ = Factor_name(indx);
Pass_P = P(:,indx)';
Pass_E = table2array(Estimate(region_order,indx))';

H = figure();
I = imagesc(Pass_E);
hold on
% Assign text
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_0 & Pass_P > threshold_1 ));
text(x, y, '*', 'VerticalAlignment', 'middle','HorizontalAlignment', 'center', 'FontSize',9);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_1 & Pass_P > threshold_2));
text(x, y, '**', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize',9);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_2));
text(x, y, '***', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize',9);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_val = min(Pass_E(:));
max_val = max(Pass_E(:))+0.01;
map_neg = brewermap(abs(round(10000*min_val)),'RdBu');
map_neg = flipud(map_neg(1+round(size(map_neg,1)/2):end,:));
map_pos = brewermap(abs(round(10000*max_val)),'RdBu');
map_pos = flipud(map_pos(1:round(size(map_pos,1)/2),:));
map_new=[map_neg;map_pos];
colormap(map_new)
cb = colorbar('TickLength', 0);
set(cb,'Position',[0.1 0.35 0.02 0.4]);% To change size
set(gcf,'position',[0 0 900 1200]);
set(gca,'fontname','times')
ax = gca;
ax.XTick = 1:length(region_name);
ax.XTickLabel = region_name;
ax.XTickLabelRotation = 45;
ax.YTick = 1:length(Factor_name_);
ax.YTickLabel = Factor_name_;
ax.YAxisLocation =  'right';
ax.FontSize = 11;
ax.TickDir = 'out';
box off

ax1 = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
    'YAxisLocation','left','Color','none','XColor','k','YColor','k');
set(ax1,'XTick', [],'YTick', []);
print(gcf,'-dpng','-r600','./Single_Association_map.png')
savefig(fullfile(save_path,'Single_Association_map.fig'));

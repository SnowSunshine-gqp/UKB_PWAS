clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
dir_path = fullfile(Project_path,'Data/PRS');
save_path = fullfile(Project_path,'Mediation analysis/PRS Modifiable');
load(fullfile(save_path,'Association_PRS_Modifiable.mat'));
load(fullfile(Project_path,'Data/Population/MRI group/MRI group info imputate.mat'),'Modifiable_info_MRI');

Modifiable_name = P_value.Properties.RowNames;
color_1 = ["FF9A9E" "A18CD1" "E64B35" "A1C4FD" "4DBBD5" "00A087" "00A087" "F093FB" "F39B7F" "30CFD0" "48C6EF"];
color_number_1 = HEX2RGB(color_1)/255;
Cate_name = unique(Modifiable_info_MRI.Domain);
for i = 1 : length(Cate_name)
    indx_ = strcmp(Cate_name{i},Modifiable_info_MRI.Domain);
    Modifiable_name(indx_) = strcat('\color[rgb]{',num2str(color_number_1(i,:)),'} ',Modifiable_name(indx_));
end

PRS_name = P_value.Properties.VariableNames';
PRS_name = strrep(PRS_name,'_','');
% define threshold of p-value
threshold_0 = 0.05/182;
threshold_1 = 0.05/182^2;
threshold_2 = 0.05/182^3;

P = table2array(P_value);
indx = logical(sum(P < threshold_0,2) >= 1);%
Modifiable_name_ = Modifiable_name(indx);
Pass_P = P(indx,:);
Pass_E = table2array(Estimate(indx,:));

H = figure();
I = imagesc(Pass_E);
hold on
% Assign text
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_0 & Pass_P > threshold_1 ));
text(x, y, '*', 'VerticalAlignment', 'middle','HorizontalAlignment', 'center', 'FontSize', 8);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_1 & Pass_P > threshold_2));
text(x, y, '**', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize', 8);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_2));
text(x, y, '***', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize', 8);
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
set(cb,'Position',[0.1 0.23 0.018 0.6]);
set(gcf,'position',[200 200 600 800]);
set(gca,'fontname','times')
ax = gca;
ax.XTick = 1:length(PRS_name);
ax.XTickLabel = PRS_name;
% ax.XTickLabelRotation = 20;
ax.YTick = 1:length(Modifiable_name_);
ax.YTickLabel = Modifiable_name_;
ax.YAxisLocation =  'right';
ax.FontSize = 8;
ax.TickDir = 'out';
box off

ax1 = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
    'YAxisLocation','left','Color','none','XColor','k','YColor','k');
set(ax1,'XTick', [],'YTick', []);
savefig(fullfile(save_path,'Single_Association_Map.fig'));

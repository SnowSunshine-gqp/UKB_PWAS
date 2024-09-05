clear,clc
Project_path = 'Work_path';
addpath(fullfile(Project_path,'Packages'));
save_path = fullfile(Project_path,'Mediation analysis/PRS Volume');

load(fullfile(save_path,'Association_PRS_Volume.mat'));

region_name = P_value.Properties.RowNames;
color_2 = ["E64B35" "4DBBD5" "00A087" "3C5488","F39B7F","8491B4"];
color_number_2 = HEX2RGB(color_2)/255;
region_name_ = regexprep(region_name,'(\<\w)','${upper($1)}');
temp_indx = [1,2,3,34,35,43];
n = 0;
for i = 1 : 43
    if sum(i == temp_indx)
        n = n + 1;
    end
    region_name_{i} = ['\color[rgb]{',num2str(color_number_2(n,:)),'} ',region_name_{i}];%
end

Factor_name = P_value.Properties.VariableNames';
Factor_name = strrep(Factor_name,'_','');
%
threshold_0 = 0.05/43;
threshold_1 = 0.05/43^2;
threshold_2 = 0.05/43^3;

P = table2array(P_value);
Pass_P = P;
Pass_E = table2array(Estimate);

H = figure();
I = imagesc(Pass_E);
hold on
% Assign text
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_0 & Pass_P > threshold_1 ));
text(x, y, '*', 'VerticalAlignment', 'middle','HorizontalAlignment', 'center', 'FontSize', 12);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_1 & Pass_P > threshold_2));
text(x, y, '**', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize', 12);
[y,x] = ind2sub(size(Pass_P),find(Pass_P < threshold_2));
text(x, y, '***', 'VerticalAlignment', 'middle','HorizontalAlignment', 'Center', 'FontSize', 12);
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
set(cb,'Position',[0.1 0.23 0.018 0.6]);% To change size
set(gcf,'position',[200 200 800 800]);
set(gca,'fontname','times')
ax = gca;
ax.XTick = 1:length(Factor_name);
ax.XTickLabel = Factor_name;
% ax.XTickLabelRotation = 20;
ax.YTick = 1:length(region_name_);
ax.YTickLabel = region_name_;
ax.YAxisLocation =  'right';
ax.FontSize = 12;
ax.TickDir = 'out';
box off
ax1 = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
    'YAxisLocation','left','Color','none','XColor','k','YColor','k');
set(ax1,'XTick', [],'YTick', []);

savefig(fullfile(save_path,'Single_Association_Map.fig'));


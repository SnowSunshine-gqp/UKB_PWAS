function RGB_list = Color_design2RGB(Color_design)
[~,m] = size(Color_design);
RGB_list = nan(m,3);
for i = 1 : m
    temp_color = Color_design(i);
    temp_color = strrep(temp_color,'#','');
    temp_color = char(temp_color);
    RGB_list(i,:) = HEX2RGB(string(temp_color(1:6)));
end
RGB_list = RGB_list./255;






function RGB = HEX2RGB(HEX)

    H=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
    n = length(HEX);
    RGB = nan(n,3);
    for i = 1 : n
        temp_HEX = HEX{i};
        for j = 1 : 3
            y(1) = find(H == temp_HEX(2*j-1))-1;
            y(2) = find(H == temp_HEX(2*j))-1;
            RGB(i,j) = y(1) * 16 + y(2);
        end
    end
end
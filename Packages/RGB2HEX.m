function HEX=RGB2HEX(RGB)
    % RGB2HEX : Achieve color RGB value conversion haex
    H=['1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','0'];
    for i=1:3
        y(1)=floor(RGB(i)/16);
        y(2)=mod(RGB(i),16);
        HEX(2*i-1)=H(y(1));
        HEX(2*i)=H(y(2));
    end
end
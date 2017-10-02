%   Get Utility
%%
function Ufull = getU(x)

    global Atts;
    global Op;
    
    u = x(1) *  Atts(1).value;
    for i = 2:Op.n
        u = u + x(i) * Atts(i).value;
    end
    Ufull = u;
end



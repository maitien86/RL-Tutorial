%   Get MUtility
%%
function Mfull = getM(x)   

    global incidenceFull; 
    global Atts;
    global Op;
    
    u = x(1) * Atts(1).value;
    for i = 2:Op.n
        u = u + x(i) * Atts(i).value; 
    end
    expM = u;
    expM(find(incidenceFull)) = exp(u(find(incidenceFull)));
    Mfull = expM;
    
end
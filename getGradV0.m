
function [gradV0] = getGradV0(M, Att, op, expV, origin)
    global isLinkSizeInclusive;
    gradExpV = getGradExpV(M, Att, op, expV);
    gradV0 = zeros(1,op.n);
    if (isLinkSizeInclusive == true)
        for i = 1:op.n
            gradV0(i) =  gradExpV(i).value(origin)/expV(origin); 
        end
    else
        for i = 1:op.n
            gradV0(i) =  gradExpV(i).Value(origin)/expV(origin); 
        end
    end
end

function [gradExpV] = getGradExpV(M, Att, op, expV)
    I = speye(size(M));  
    A = I - M; 
    global isLinkSizeInclusive;
    if (isLinkSizeInclusive == true)       
        gradExpV = objArray(op.n); 
        for i = 1:op.n
            u = M .* (Att(i).value); 
            v = u * expV; 
            gradExpV(i).value = A\v;
        end
    else
        for i = 1:op.n
            u = M .* (Att(i).Value); 
            v = u * expV; 
            gradExpV(i) = Matrix2D(A\v); 
        end
    end
end














































































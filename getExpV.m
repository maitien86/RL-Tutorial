% Get e^V(k)
%%
function [expV, boolV0] = getExpV(M)
    boolV0 = 1;
    [n m]= size(M);
    b = zeros(n,1);
    b(n)=1;
    b_sp = sparse(b);    
    I = speye(size(M));  
    A = I - M; 
    Z = A\b_sp;
    
    % test "values smaller than 0"
    minele = min(Z);
    if minele == 0 || minele < OptimizeConstant.NUM_ERROR
        boolV0 = 0;
    end  
    
    % set values smaller than real min to realmin
    Z(Z<realmin) = realmin;
    
    % set negative values (if any) to positive ones
    Zabs = abs(Z); 
    
    %test "still solution of system after making neg elements positive"
    resNorm = norm(A * Zabs - b_sp);
    if resNorm > OptimizeConstant.RESIDUAL
        boolV0 = 0;
    end

    expV = full(Zabs);
end

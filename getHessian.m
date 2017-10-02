%   Get analytical Hessian matrix
%   Link size is included
%%
function Hessian = getHessian()
   %[~,~,Hessian,~] = getAnalyticalHessian();    
      global Op;
    x = Op.x;
    step = 1e-8;
    H = eye(Op.n) * step;
    Hessian = zeros(Op.n);
    [~, grad1] = LL(Op.x);
    for i= 1 : Op.n
        Op.x = x + H(:,i);  
        [~, grad2] = LL(Op.x);
        Hessian(:,i) = (grad2 - grad1)/step;
    end
    Op.x = x;
end
% Combined approximation for Hessian update.
% Refer to the structure of the mathematical formula of Hessian
%% 
function [H ok] = RouteChoice_approx(sk)
    global Op;
    global nbobs;
    global PrevGradient;
    global Gradient;
    H = zeros(Op.n);
    deltaGrad = - Gradient + PrevGradient;
    for i = 1: nbobs
        [Op.Hi(i).value ok] = BFGS(sk, deltaGrad(i,:)', Op.Hi(i).value); 
        H = H + (Op.Hi(i).value - H)/i;
    end    
    H = -H;
end
%   Initialize optimization structure
%%
function [] = initialize_optimization_structure()
    global Op;
    global isLinkSizeInclusive;
    Op.Optim_Method = OptimizeConstant.TRUST_REGION_METHOD;
    Op.Hessian_approx = OptimizeConstant.BFGS; 
    Op.ETA1 = 0.05;
    Op.ETA2 = 0.75;
    Op.maxIter = 150;
    Op.k = 0;
    Op.n = 3;
    if isLinkSizeInclusive == true
        Op.n = Op.n + 1;
    end
    Op.x = -ones(Op.n,1) * 1.5;
    Op.tol = 1e-6;
    Op.radius = 1.0;
    Op.Ak = eye(Op.n);
    Op.H = eye(Op.n);
end
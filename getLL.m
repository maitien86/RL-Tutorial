% Compute the loglikelihood value and its gradient.
%%
function [LL, grad] = getLL()

    global incidenceFull; 
    global Gradient;
    global Op;
    global Mfull;
    global Ufull;
    global Atts;
    global Obs;    
    global nbobs;  
    global isLinkSizeInclusive;
    global SampleObs;
    
    % If the likelihood is computed on a sample
    if isempty(SampleObs)
        SampleObs = 1:nbobs;
    end
    sample = SampleObs;

    % If Link size is included: call other function
    if (isLinkSizeInclusive == true)
        [LL, grad] = getODspecLL();
        return;
    end
    
    mu = 1;
    
    % get M and U
    [lastIndexNetworkState, maxDest] = size(incidenceFull);    
    Mfull = getM(Op.x);
    MregularNetwork = Mfull(1:lastIndexNetworkState,1:lastIndexNetworkState);
    Ufull = getU(Op.x);
    UregularNetwork = Ufull(1:lastIndexNetworkState,1:lastIndexNetworkState);
    
    % Set LL value and gradient
    LL = 0;
    grad = zeros(1, Op.n);
    
    % Initialize
    M = MregularNetwork;
    M(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
    M(lastIndexNetworkState+1,:) = sparse(zeros(1, lastIndexNetworkState + 1));
    U = UregularNetwork;
    U(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
    U(lastIndexNetworkState+1,:) = sparse(zeros(1, lastIndexNetworkState + 1));
    for i = 1:Op.n
        AttLc(i) =  Matrix2D(Atts(i).value(1:lastIndexNetworkState,1:lastIndexNetworkState));
        AttLc(i).Value(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
        AttLc(i).Value(lastIndexNetworkState+1,:) = sparse(zeros(1, lastIndexNetworkState + 1));
    end
    
    % Compute exponential of value function Z
    N = size(M,1);
    B = sparse(zeros(N, maxDest - lastIndexNetworkState));
    B(N,:) = ones(1,maxDest - lastIndexNetworkState);
    for i = 1: maxDest - lastIndexNetworkState
        B(1:lastIndexNetworkState,i) = Mfull(:, i+lastIndexNetworkState);
    end
    A = speye(size(M)) - M;
    Z = A\B;
    
    % Check feasibility of Z
    minele = min(Z(:));
    expVokBool = 1;
    if minele < -1e-5 %|| minele < OptimizeConstant.NUM_ERROR
       expVokBool = 0;
    end 
    D = (A * Z - B);
    resNorm = norm(D(:));
    if resNorm > OptimizeConstant.RESIDUAL
       expVokBool = 0;
    end
    if (expVokBool == 0)
        LL = OptimizeConstant.LL_ERROR_VALUE;
        grad = ones(Op.n,1);
        disp('The parameters not fesible')
        return; 
    end
    
    % Compute gradient of Z
    gradExpV = objArray(Op.n);
    for i = 1:Op.n
        u = M .* (AttLc(i).Value); 
        v = sparse(u * Z); 
        p = Atts(i).value(:,lastIndexNetworkState+1 : maxDest) .* Mfull(:,lastIndexNetworkState+1 : maxDest);
        p(lastIndexNetworkState+1,:) = sparse(zeros(1,maxDest - lastIndexNetworkState));        
        p = sparse(p);
        gradExpV(i).value =  sparse(A\(v + p)); 
    end
    
    % Loop on all observations
    % Compute the LL and gradient.
    for n = 1:nbobs    
        dest = Obs(sample(n), 1);
        orig = Obs(sample(n), 2);
        expV = Z(:,dest - lastIndexNetworkState);
        expV = full(abs(expV));         
        lnPn = - 1 * (1/mu) * log(expV(orig));
        for i = 1: Op.n
            Gradient(n,i) = - gradExpV(i).value(orig,dest - lastIndexNetworkState)/expV(orig);
        end
        
        sumInstU = 0;
        sumInstX = zeros(1,Op.n);
        
        path = Obs(sample(n),:);
        lpath = size(find(path),2);
        % Compute regular attributes
        for i = 2:lpath - 1
            sumInstU = sumInstU + Ufull(path(i),path(i+1));
            for j = 1:Op.n
                sumInstX(j) = sumInstX(j) + Atts(j).value(path(i),path(i+1));
            end
        end
        Gradient(n,:) = Gradient(n,:) + sumInstX;
        lnPn = lnPn + (1/mu)*sumInstU ;  
        LL =  LL + (lnPn - LL)/n;
        grad = grad + (Gradient(n,:) - grad)/n;
        Gradient(n,:) = - Gradient(n,:);
    end

    LL = -1 * LL;
    grad =  - grad';
end

%%
% Compute loglikelihood value with link size attribute 
%-----------------------------------------------------
function [LL, grad] = getODspecLL()

    global incidenceFull; 
    global Gradient;
    global Op;
    global Mfull;
    global Ufull;
    global Atts;
    global Obs;
    global nbobs;  
    global LSatt;
    global LinkSize;
    global SampleObs;
    global RealOD;
    
    if isempty(SampleObs)
        SampleObs = 1:nbobs;
    end
    sample = SampleObs;
  
    mu = 1; 
    [lastIndexNetworkState, maxDest] = size(incidenceFull);
    LL = 0;
    grad = zeros(1, Op.n);
    
    % For the OD-independent attributes
    AttLc = objArray(Op.n);
    for i = 1 : Op.n - 1
        AttLc(i).value= Atts(i).value(1:lastIndexNetworkState,1:lastIndexNetworkState); %without .value=  Matrix2D(Atts(i).value(1:lastIndexNetworkState,1:lastIndexNetworkState));
        AttLc(i).value(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
        AttLc(i).value(lastIndexNetworkState+1,:) = sparse(zeros(1, lastIndexNetworkState + 1));
    end
    % Loop over all observation
    RealOD = Obs(sample(1:nbobs),1:2);
    for t = 1:nbobs
        dest = Obs(sample(t), 1);
        orig = Obs(sample(t), 2);
        m = find(ismember(Obs(:,1:2),[dest,orig],'rows'),1);
        % For the OD-specific attribute (Link Size)
        LinkSize = LSatt(m).value;       
        Atts(Op.n).value = LinkSize;
        AttLc(Op.n).value = LinkSize(1:lastIndexNetworkState,1:lastIndexNetworkState);
        AttLc(Op.n).value(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
        AttLc(Op.n).value(lastIndexNetworkState+1,:) = sparse(zeros(1, lastIndexNetworkState + 1));       
        if true   
            % Get M and U
            Mfull = getM(Op.x); % matrix with exp utility for given beta
            M = Mfull(1:lastIndexNetworkState,1:lastIndexNetworkState);            
            addColumn = Mfull(:,dest);
            M(:,lastIndexNetworkState+1) = addColumn;
            M(lastIndexNetworkState+1,:) = zeros(1,lastIndexNetworkState+1);
            [Z, expVokBool] = getExpV(M); % vector with value functions for given beta                                                                     
            if (expVokBool == 0)
                LL = OptimizeConstant.LL_ERROR_VALUE;
                grad = ones(Op.n,1);
                disp('The parameters are not fesible')
                return; 
            end    
            expV0 = Z(orig);
            gradV0 = getGradV0(M, AttLc, Op, Z, orig);   %Here we compute the gradient based on both M and AttLC         
        end                
        % Get Utility
        Ufull = getU(Op.x); % matrix of utility for given beta
        U = Ufull(1:lastIndexNetworkState,1:lastIndexNetworkState);            
        addColumn = Ufull(:,dest);
        U(:,lastIndexNetworkState+1) = addColumn;
        U(lastIndexNetworkState+1,:) = zeros(1,lastIndexNetworkState+1);       
        sumInstU = 0;
        sumInstX = zeros(1,Op.n);
        seq = 2;
        a = Obs(sample(t),seq+1); % action state after origin
        lnPn = - 1 * ((1/mu) * log(expV0));
        Gradient(t,:) = - gradV0;
        path = Obs(sample(t),:);
        lpath = size(find(path),2);
        for i = 2:lpath - 1
            mIndex = min(path(i+1), lastIndexNetworkState +1);
            sumInstU = sumInstU + U(path(i),mIndex) ;
            for j = 1:Op.n
                sumInstX(j) = sumInstX(j) + AttLc(j).value(path(i),mIndex);
            end          
        end         
        Gradient(t,:) = - gradV0 + sumInstX;
        lnPn = lnPn + ((1/mu)*sumInstU) ;  
        LL =  LL + (lnPn - LL)/t;
        grad = grad + (Gradient(t,:) - grad)/t;
        Gradient(t,:) = - Gradient(t,:);
    end
    LL = -1 * LL; % IN ORDER TO HAVE A MIN PROBLEM
    grad =  - grad';
end
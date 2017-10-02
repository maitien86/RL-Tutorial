function [ sumF ] = ComputeLinkFlowsTraffic( ODmatrix, beta, Pi )
%Computes expected link flows as a solution of system of linear equations
%   ODmatrix : matrix describing the number of individuals traveling on
%   each OD pair (rows for O, columns for D)
%   beta : vector of utility parameters to use

global incidenceFull; 
global Mfull;
global LSatt;
global Atts;

% get network data
loadData;

% set number of destinations from OD matrix
nbDest=sum(~all(ODmatrix == 0, 1));

% get M
[lastIndexNetworkState, ~] = size(incidenceFull);
if length(beta) ~= size(Atts,2)
    disp('The length of the beta vector must coincide with the number of attributes')
    sumF = zeros(lastIndexNetworkState,1);
    return 
end
u = beta(1) * Atts(1).value;
for i = 2:length(beta)
    u = u + beta(i) * Atts(i).value; 
end
expM = u;
expM(find(incidenceFull)) = exp(u(find(incidenceFull)));
Mfull = expM;    
M = Mfull(1:lastIndexNetworkState,1:lastIndexNetworkState); 
M(:,lastIndexNetworkState+1) = sparse(zeros(lastIndexNetworkState,1));
M(lastIndexNetworkState+1,:) = sparse(zeros(1,lastIndexNetworkState + 1));

% initialize flow vectors
sumF=zeros(lastIndexNetworkState,1);
ProblemWithFlow=0;
F=zeros(lastIndexNetworkState+1,nbDest);

for n = 1:nbDest 
    destlink = lastIndexNetworkState+n;
    if true %expV0(dest) == 0   
        M(1:lastIndexNetworkState ,lastIndexNetworkState + 1) = Mfull(:,destlink);
        [expV, expVokBool] = TestgetExpV(M,Pi);
        if (expVokBool == 0)
            disp('ExpV is not feasible')
            return; 
        end  
        P=TestgetP(expV,M);
    end
    Pchoice=P;
    P=Pchoice*Pi;
    G = ODmatrix(:,destlink);
    G(lastIndexNetworkState+1)=0;
    I = speye(size(P));
    F(:,n) = (I-P')\G;   
    if (min(F(:,n)) < 0)                
        ToZero = find(F(:,n) <= 0);
        for i=1:size(ToZero,1)
            F(ToZero(i),n) = 1e-9;
        end
    end
    ips = F(:,n);
    ips = ips(1:lastIndexNetworkState); % dummy link should not be included
    if any(isnan(ips))
        ProblemWithFlow=ProblemWithFlow+1;
    else
        sumF = sumF+ips;
    end
end
end




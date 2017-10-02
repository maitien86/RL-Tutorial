% Testing link flow assignment with congestion

global incidenceFull;
global Atts;

% get network data
loadData;
[lastIndexNetworkState, ~] = size(incidenceFull);

% set beta and OD matrix
%beta=-0.05;
beta=-1;
ODmatrix=sparse(zeros(size(incidenceFull)));
ODmatrix(1,9)=10;

% set capacities of links
capacities=ones(lastIndexNetworkState,1) * sum(sum(ODmatrix));
capacities(7)=5;
%capacities(3)=2;

% compute link flows
F = ComputeLinkFlows(ODmatrix, beta);

% compute action-state transition probabilities
Pi = sparse(zeros(size(incidenceFull)));
Pi(lastIndexNetworkState+1,:)=sparse(zeros(1,lastIndexNetworkState+1));
for j=1:lastIndexNetworkState+1
    Pi(j,j)=1;
end
for j=1:7%length(F)
    if F(j) > capacities(j)
        found=find(incidenceFull(:,j));
        Pi(j,j)=capacities(j)/F(j);
        found2=find(incidenceFull(found(1),:));
        for k=1:length(found2)
            if found2(k)~=j
                Pi(j,found2(k))=(F(j)-capacities(j))/(F(j)*(length(found2)-1));
            end
        end       
    end
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

for k=1:10
    % compute new value function
    expV=TestgetExpV(M,Pi);

    % compute new proba
    P=TestgetP(expV,M);

    % compute new link flows
    F=TestComputeLinkFlows(ODmatrix, beta, Pi);
    
    % store old value of Pi(7,7)
    olddev=Pi(7,7);
    
    % compute new Pi
    Pi = sparse(zeros(size(incidenceFull)));
    Pi(lastIndexNetworkState+1,:)=sparse(zeros(1,lastIndexNetworkState+1));
    for j=1:lastIndexNetworkState+1
        Pi(j,j)=1;
    end
    for j=1:7%length(F)
        if F(j) > capacities(j)
            found=find(incidenceFull(:,j));
            Pi(j,j)=capacities(j)/F(j);
            found2=find(incidenceFull(found(1),:));
            for k=1:length(found2)
                if found2(k)~=j
                    Pi(j,found2(k))=(F(j)-capacities(j))/(F(j)*(length(found2)-1));
                end
            end
        end       
    end
    delta=olddev-Pi(7,7);
end

% compute state-state transition probabilities
%FTraffic = ComputeLinkFlowsTraffic(ODmatrix, beta, Pi);
function [ expV, bool ] = TestgetExpV( M, Pi )
% Summary of this function goes here
%   Detailed explanation goes here
    global incidenceFull
    
    [lastIndexNetworkState, maxDest] = size(incidenceFull);
    N=size(M,1);
    expV=0.001*ones(N,1);
    expV(end)=1;
    found=logical(incidenceFull(:,lastIndexNetworkState+1));
    expV(found)=1;
    
    expV(5)=dot(M(5,:),expV);
    EV=exp(Pi*log(expV));
    expV(3)=dot(M(3,:),EV);
    expV(4)=dot(M(4,:),EV);
    expV(2)=dot(M(2,:),expV);
    expV(1)=dot(M(1,:),expV);
    bool=1;
    
end


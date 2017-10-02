%   Computes the probability for each state action pair
%%
function P = getP(expV, M)    
    N = size(M,1);
    MI = M; 
    MI(find(M)) = 1; 
%    expV(expV<realmin)=realmin;
    invexpV=1./expV;    
    Zdiag =  spdiags(expV,0,N,N);
    invZdiag =  spdiags(invexpV,0,N,N);
    
    P = M .* (invZdiag * MI * Zdiag);
end

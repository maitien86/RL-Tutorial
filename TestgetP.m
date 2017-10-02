function [ P ] = TestgetP( expV,M )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    n = size(M,1);
    I = find(M);
    [nbnonzero, c] = size(I);
    ind1 = zeros(nbnonzero,1);
    ind2 = zeros(nbnonzero,1);
    s = zeros(nbnonzero,1);
    for i=1:nbnonzero
        [k a] = ind2sub(size(M), I(i));
        ind1(i) = k;
        ind2(i) = a;
        sum=dot(M(k,:),expV);
        s(i) =  M(k,a) * expV(a)/sum;
    end    
    P = sparse(ind1, ind2, s, n, n);
end


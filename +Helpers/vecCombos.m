function [ combos ] = vecCombos( vec1, vec2 )
%FNCHOOSEK Summary of this function goes here
%   Detailed explanation goes here
    n = length(vec1);
    m = length(vec2);
    
    combos = zeros(nchoosek(N,2),2);
    for i = 1:N-1
        start = nchoosek(N, 2) - nchoosek(N - i + 1, 2) + 1;
        if N-i == 1
            fin = length(combos);
        else
            fin = nchoosek(N, 2) - nchoosek(N-i, 2);
        end
        combos(start:fin, 1) = nums(i);
        combos(start:fin, 2) = nums(i+1:end);
    end
end

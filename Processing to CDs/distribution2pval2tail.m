function [ pval ] = distribution2pval2tail( distribution,scores )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

    pval = ones(numel(scores),1);
    for i = 1:numel(scores)
        pval(i) = sum(distribution<=scores(i))/numel(distribution)*2;
    end
end


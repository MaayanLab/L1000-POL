function [ mat,constantGenesIdx ] = removeConstantGenes( mat,thres)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    thres = 0.02; %threshold learned from the dataset.
%     key=[];
end

rowStd = std(mat,0,2);
constantGenesIdx = find(rowStd < thres);
mat(constantGenesIdx,:) = [];

end


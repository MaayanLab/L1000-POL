function [ res ] = cumusumRandSample( unitV,repCount )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

permuCount = 10000;
[repCountUnique,~] = count_unique(repCount);
noDistIdx = repCountUnique == 1; % no between-rep distance if there is only one rep.
repCountUnique(noDistIdx) = [];
expmCount = size(unitV,2);

for i = 1:numel(repCountUnique)
    currentRepCount = repCountUnique(i);
    nullCumsum = zeros(size(unitV,1),permuCount);
    for j = 1:permuCount
        sampleIdx = randsample(expmCount,currentRepCount);
        samples = unitV(:,sampleIdx);
        cd = mean(samples,2);
        cd = cd/norm(cd);
        cd2 = cd.^2;
        nullCumsum(:,j) = cumsum(sort(cd2,'descend'));
    end
%     eval(sprintf('res.cumsum%d = nullRps(:);',currentRepCount));
    eval(sprintf('res.cumsum%d = nullCumsum;',currentRepCount));

end

end


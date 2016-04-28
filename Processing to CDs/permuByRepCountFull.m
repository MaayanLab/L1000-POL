function [ res ] = permuByRepCountFull( unitV,repCount )
% calculate empirical null distribution of chdir repliacates by 100000 permutation 
% Input:
%   unitV: (978*n) matrix, all chdir replicates of all experiments in a batch,
%                    n is the number of chdir reps of all experiments in a batch.
%   repCount: vector of length m, store replicate count of each experiment
%              in the batch. m equals to the number of experiments in the
%              batch
%
% generate a distributioni for each count >=2

permuCount = 10000;
[repCountUnique,~] = count_unique(repCount);
noDistIdx = repCountUnique == 1; % no between-rep distance if there is only one rep.
repCountUnique(noDistIdx) = [];
expmCount = size(unitV,2);

for i = 1:numel(repCountUnique)
    currentRepCount = repCountUnique(i);
    nullRps = zeros(size(unitV,1),permuCount);
    for j = 1:permuCount
        permu = randperm(expmCount,currentRepCount);
        sample = unitV(:,permu);
        [~,sortIdx] = sort(sample.^2,1,'descend');
        [~,rank] = sort(sortIdx,1);
        rp = prod(rank,2).^(1/currentRepCount);
        nullRps(:,j) = rp;
    end
    eval(sprintf('res.rp%d = nullRps(:);',currentRepCount));
    eval(sprintf('res.rpm%d = nullRps;',currentRepCount));

end
end





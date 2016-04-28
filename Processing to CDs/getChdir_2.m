function [ expmArr ] = getChdir_2( arr,lmIdx )
%Calculate chdir for each experiment replicate.
%   Detailed explanation goes here

% check if ctl_vehicle is the only one
ctrlIdx = cellfun(@(x)strcmp(x.pert_type,'ctl_vehicle'), arr, 'UniformOutput',false);
ctrlIdx = [ctrlIdx{:}];
expmIdx = ~ctrlIdx;

ctrlArr = arr(ctrlIdx);
ctrlMat = cellfun(@(x)x.data, ctrlArr, 'UniformOutput',false);
ctrlMat = [ctrlMat{:}];
expmArr = arr(expmIdx);

ctrlLmMat = ctrlMat(lmIdx,:);
dists = squareform(pdist(ctrlLmMat'));
avgDist = sum(dists)/(numel(ctrlArr)-1);
ctrlOutlierIdx = outlier(avgDist,0.01);


ctrlMat(:,ctrlOutlierIdx) = [];
ctrlLmMat(:,ctrlOutlierIdx) = [];
if ~isempty(ctrlOutlierIdx)
disp('Number of removed outliers in Control:');
disp(numel(ctrlOutlierIdx));
end


disp('begin calculate chdir');
totalCount = numel(expmArr);
parfor i = 1:totalCount
    expmVector = expmArr{i}.data;
    expmLmVector = expmVector(lmIdx);
    
    
    [~,rmIdxLm] = removeConstantGenes(ctrlLmMat);
    ctrlLmMatCleaned = ctrlLmMat;
    ctrlLmMatCleaned(rmIdxLm,:) = [];
    expmLmVectorCleaned = expmLmVector;
    expmLmVectorCleaned(rmIdxLm) = [];
    unitVLm = chdirLm(ctrlLmMatCleaned,expmLmVectorCleaned);
    unitVLm = insertRemovedGenes(unitVLm,rmIdxLm);
    
    
    [~,rmIdxFull] = removeConstantGenes(ctrlMat);
    ctrlMatCleaned = ctrlMat;
    ctrlMatCleaned(rmIdxFull,:) = [];
    expmVectorCleaned = expmVector;
    expmVectorCleaned(rmIdxFull) = [];
    unitVFull= chdirLm(ctrlMatCleaned,expmVectorCleaned);
    unitVFull = insertRemovedGenes(unitVFull,rmIdxFull);
  
    
    expmArr{i}.chdirLm = unitVLm;
    expmArr{i}.chdir = unitVFull;
end
end


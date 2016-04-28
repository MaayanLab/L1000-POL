
ctrlIdx = cellfun(@(x)strcmp(x.pert_type,'ctl_vehicle'), arr, 'UniformOutput',false);
ctrlIdx = [ctrlIdx{:}];
expmIdx = ~ctrlIdx;

ctrlArr = arr(ctrlIdx);
ctrlMat = cellfun(@(x)x.data, ctrlArr, 'UniformOutput',false);
ctrlMat = [ctrlMat{:}];
expmArr = arr(expmIdx);

ctrlLmMat = ctrlMat(lmIdx,:);

% % remove outlier in a multivariate way
ctrlOutlierIdx = moutlier1(ctrlLmMat',0.05);
% ctrlMat(:,ctrlOutlierIdx) = [];
ctrlLmMat(:,ctrlOutlierIdx) = [];
if ~isempty(ctrlOutlierIdx)
disp('Number of removed outliers in Control:');
disp(numel(ctrlOutlierIdx));
end

totalCount = numel(expmArr);
for i = 1%:totalCount
    tic
    fprintf('caculates chdir: %d/%d',i,totalCount);
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
%     expmArr{i}.sigCount = sigCount;
    toc
end



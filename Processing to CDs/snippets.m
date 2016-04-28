sampleCount = 10000
rankNull = sort(cosDist.repCount2);
cutoff = rankNull(sampleCount*0.05)
cutoff = rankNull(sampleCount*0.01)

rankNull = sort(cosDist.repCount3);
cutoff = rankNull(sampleCount*0.05)
cutoff = rankNull(sampleCount*0.01)


rankNull = sort(cosDist.rp3);
sampleCount = numel(rankNull);
cutoff = rankNull(sampleCount*0.01)
cosDist.rp3cutoff = cutoff;

rankNull = sort(cosDist.rp2);
sampleCount = numel(rankNull);
cutoff = rankNull(sampleCount*0.01)
cosDist.rp2cutoff = cutoff;



sigLevel = 0.01;
diffCount = zeros(numel(sigIdStructs),1);
comp = zeros(numel(sigIdStructs),2);
for i = 1:numel(sigIdStructs)
    tic
    sigIdStruct = sigIdStructs{i};
    chdir = sigIdStruct.x0x5F_id;
    chdir.replicateCount = sigIdStruct.replicateCount;
    if sigIdStruct.replicateCount>1
        chdirReplicates = dict(chdirStructsAllPlates,@(x)strcmp(x.pert_id,sigIdStruct.x0x5F_id.pert_id)&&strcmp(x.pert_dose,sigIdStruct.x0x5F_id.pert_dose));
        chdirVectorsLm = cellfun(@(x)x.chdirLm,chdirReplicates,'UniformOutput',false);
        chdirVectorsLm = [chdirVectorsLm{:}];
        chdirVectors = cellfun(@(x)x.chdir,chdirReplicates,'UniformOutput',false);
        chdirVectors = [chdirVectors{:}];
         chdirMeanDist = mean(pdist(chdirVectorsLm','cosine'));
         chdirMean = mean(chdirVectors,2);
         chdirMean = chdirMean/norm(chdirMean);
         [~,meanSortIdx] = sort(chdirMean.^2,'descend');
        [~,sortIdx] = sort(chdirVectors.^2,1,'descend');
        [~,rank] = sort(sortIdx,1);
        rp = prod(rank,2).^(1/size(rank,2));
        [sortRp,sortIdx] = sort(rp);
        eval(sprintf('diffIdx = rp<=cosDist.rp%dcutoff;',sigIdStruct.replicateCount));
        diffCount(i) = sum(diffIdx);
        comp(i,1) = numel(intersect(sortIdx(1:diffCount(i)),meanSortIdx(1:diffCount(i))));
        comp(i,2) = sum(diffIdx);
%         figure;plot(sortRp);
    end
    toc
end




sigLevel = 0.01;
diffCount = zeros(numel(sigIdStructs),1);
% comp = zeros(numel(sigIdStructs),2);
for i = 1:numel(sigIdStructs)
    tic
    sigIdStruct = sigIdStructs{i};
    chdir = sigIdStruct.x0x5F_id;
    chdir.replicateCount = sigIdStruct.replicateCount;
    if sigIdStruct.replicateCount>1
        chdirReplicates = dict(chdirStructsAllPlates,@(x)strcmp(x.pert_id,sigIdStruct.x0x5F_id.pert_id)&&strcmp(x.pert_dose,sigIdStruct.x0x5F_id.pert_dose));
        chdirVectorsLm = cellfun(@(x)x.chdirLm,chdirReplicates,'UniformOutput',false);
        chdirVectorsLm = [chdirVectorsLm{:}];
        chdirVectors = cellfun(@(x)x.chdir,chdirReplicates,'UniformOutput',false);
        chdirVectors = [chdirVectors{:}];
        
         chdirMeanDist = mean(pdist(chdirVectorsLm','cosine'));
         chdirMean = mean(chdirVectors,2);
         chdirMean = chdirMean/norm(chdirMean);
         [~,meanSortIdx] = sort(chdirMean.^2,'descend');
         [~,meanRank] = sort(meanSortIdx);
        [~,sortIdx] = sort(chdirVectors.^2,1,'descend');
        [~,rank] = sort(sortIdx,1);
        rp = prod(rank,2).^(1/size(rank,2));
        rpv = (rp.*meanRank).^(1/2);
        [sortRp,sortIdx] = sort(rpv);
        eval(sprintf('diffIdx = rpv<=cosDist.rp%dcutoff;',sigIdStruct.replicateCount));
        diffCount(i) = sum(diffIdx);
%         figure;plot(sortRp);
    end
    toc
end




res = ones(numel(sigIdStructs),1)*1;
for i = 1:numel(sigIdStructs)
    sigIdStruct = sigIdStructs{i};
    chdir = sigIdStruct.x0x5F_id;
    chdir.replicateCount = sigIdStruct.replicateCount;
    if sigIdStruct.replicateCount>1
        chdirReplicates = dict(chdirStructsAllPlates,@(x)strcmp(x.pert_id,sigIdStruct.x0x5F_id.pert_id)&&strcmp(x.pert_dose,sigIdStruct.x0x5F_id.pert_dose));
        chdirVectors = cellfun(@(x)x.chdirLm,chdirReplicates,'UniformOutput',false);
        chdirVectors = [chdirVectors{:}];
        avgChdir = mean(chdirVectors,2);
        chdirMeanDist = mean(pdist(chdirVectors','cosine'));
        res(i) = chdirMeanDist;
    end
end

pvals = NaN(numel(chdirs),1);
sigCount = NaN(numel(chdirs),1);
for i = 1:numel(chdirs)
    if isfield(chdirs{i},'pvalue');
        pvals(i) = chdirs{i}.pvalue;
    end
    if isfield(chdirs{i},'sigIdx');
        sigCount(i) = numel(chdirs{i}.sigIdx);
    end
end
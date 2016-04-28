function [ chdirs ] = mergeReplicates( platesRes,sigIdStructs)
%Merge chdir replicates and computes the significance.
%   Detailed explanation goes here
disp('start merge replicates');

chdirStructsAllPlates = [platesRes{:}];

% chdirLm = cellfun(@(x)x.chdirLm, chdirStructsAllPlates,'UniformOutput',false);
chdirLm = cellfun(@(x)x.chdirLm, chdirStructsAllPlates,'UniformOutput',false);
chdirLm = [chdirLm{:}];

chdirFull = cellfun(@(x)x.chdir, chdirStructsAllPlates,'UniformOutput',false);
chdirFull = [chdirFull{:}];

repCount = cellfun(@(x)numel(x.distil_id),sigIdStructs,'UniformOutput',false);
repCount = [repCount{:}];

% caculate cosine distance null distribution.
% about 90 seconds execution time for 360 experiments
cosDistLm = permuByRepCount(chdirLm,repCount);
cosDistFull = permuByRepCountFull(chdirFull,repCount);
cumsumsFull = cumusumRandSample(chdirFull,repCount);

sigLevel = 0.01;

rpKeys = fieldnames(cosDistFull);
for i = 1:numel(rpKeys)
    eval(sprintf('rankNull = sort(cosDistFull.%s);',rpKeys{i}));
    sampleCount = numel(rankNull);
    cutoff = rankNull(sampleCount*sigLevel);
    eval(sprintf('cosDistFull.%scutoff = cutoff;',rpKeys{i}));
end


chdirs = cell(numel(sigIdStructs),1);
degCount = zeros(numel(sigIdStructs),1);
meanDists = NaN(numel(sigIdStructs),1);

for i = 1:numel(sigIdStructs)
    disp(i);
    sigIdStruct = sigIdStructs{i};
    sigIdStruct.replicateCount = numel(sigIdStruct.distil_id);
    chdir = sigIdStruct;
    if sigIdStruct.replicateCount==1
        chdirReplicate = dict(chdirStructsAllPlates,@(x)strcmp(x.distil_id,sigIdStruct.distil_id{1}));
        chdir.chdirLm = chdirReplicate.chdirLm';
        chdir.chdirFull = chdirReplicate.chdir';
        chdirs{i} = addFields(chdir,chdirReplicate);
    else
        chdirReplicates = dict(chdirStructsAllPlates,@(x)any(strcmp(x.distil_id,sigIdStruct.distil_id)));
        chdirVectorsLm = cellfun(@(x)x.chdirLm,chdirReplicates,'UniformOutput',false);
        chdirVectorsLm = [chdirVectorsLm{:}];
        meanChdirVectorLm = mean(chdirVectorsLm,2);
        chdir.chdirLm = (meanChdirVectorLm/norm(meanChdirVectorLm))';
        chdirMeanDistLm = mean(pdist(chdirVectorsLm','cosine'));
        eval(sprintf('cosDistByRepCount = cosDistLm.repCount%d;',chdir.replicateCount));
        chdir.pvalue = distribution2pval(cosDistByRepCount,chdirMeanDistLm);
        chdir.chdirMeanDistLm = chdirMeanDistLm;
        meanDists(i) = chdirMeanDistLm;
        
         % meanChdirFull criterion
        chdirVectorsFull = cellfun(@(x)x.chdir,chdirReplicates,'UniformOutput',false);
        chdirVectorsFull = [chdirVectorsFull{:}];
        meanChdirVectorFull = mean(chdirVectorsFull,2);
        chdir.chdirFull = (meanChdirVectorFull/norm(meanChdirVectorFull))';
        
        [sortedCd2,sortIdx] = sort(chdir.chdirFull.^2,'descend');
        cdCumsum = cumsum(sortedCd2);
        p = zeros(1000,1);
        for j = 1:1000
            eachCumsum = cdCumsum(j);
             eval(sprintf('p(j) = sum(cumsumsFull.cumsum%d(j,:)>=eachCumsum)/size(cumsumsFull.cumsum%d,2);',...
                 chdir.replicateCount,chdir.replicateCount));
        end
        
        [minP,minIdx] = min(p);
        if minP <= 0.1
            chdir.sigIdx = sortIdx(1:minIdx);
            degCount(i) = minIdx;
        end
        
        chdirs{i} = addFields(chdir,chdirReplicates{1});
    end
end


% adjustIdx = (meanDists>=1);
% adjustCount = mean(sigCount(adjustIdx));
% 
% for i = 1:numel(sigIdStructs)    
%     currentSigCount = floor(sigCount(i)-adjustCount);
%     if currentSigCount<=0 
%         chdirs{i} = rmfield(chdirs{i},'sigIdx');
%     elseif ~isnan(currentSigCount)
%         chdirs{i}.sigIdx=chdirs{i}.sigIdx(1:currentSigCount)';
%     end
% end

disp('replicates Merged');
end




function [elems] = dict(arr,matchFunc)

   matchIdx = cellfun(matchFunc,arr,'UniformOutput',false);
   matchIdx = [matchIdx{:}];
   elems = arr(matchIdx);
   if numel(elems)==1
       elems = elems{1};
   end

end
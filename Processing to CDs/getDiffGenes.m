function [ chdir ] = getDiffGenes( chdir,meanChdirVectorFull,chdirReplicates,genes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sigCounts = cellfun(@(x)x.sigCount,chdirReplicates);
avgSigCount = mean(sigCounts);

[sortChdirSquare,sortIdx] = sort(meanChdirVectorFull.^2,'descend');
diffChdirSqure = sortChdirSquare(1:avgSigCount);
scale = scaleRange([diffChdirSqure(end),diffChdirSquare(1)],[0.1,1]);
upGenes = {};
dnGenes = {};
upGenesMembership = [];
dnGenesMembership = [];
for i = 1:avgSigCount
   geneIdx = sortIdx(i);
   componentVal = meanChdirVectorFull(geneIdx);
   if componentVal>0
       upGenes = [upGenes;{genes(geneIdx)}];
       upGenesMembership = [upGenesMembership scale(componentVal^2)];
   else
       dnGenes = [dnGenes;{genes(geneIdx)}];
       dnGenesMembership = [dnGenesMembership scale(componentVal^2)];
   end
       
end

chdir.upGense = upGenes;
chdir.upGenesMembership = upGenesMembership;
chdir.dnGenes = dnGenes;
chdir.dnGenesMembership = dnGenesMembership;

end


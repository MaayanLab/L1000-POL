function [ chdir ] = getDiffGenes1( chdir,chdirReplicate,genes )
%for one replicate
%   Detailed explanation goes here

[sortChdirSquare,sortIdx] = sort(chdirReplicate.chdir.^2,'descend');
diffChdirSqure = sortChdirSquare(1:chdirReplicate.sigCount);

scale = scaleRange([diffChdirSqure(end),diffChdirSquare(1)],[0.1,1]);
upGenes = {};
dnGenes = {};
upGenesMembership = [];
dnGenesMembership = [];
for i = 1:avgSigCount
   geneIdx = sortIdx(i);
   componentVal = chdirReplicate(geneIdx);
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


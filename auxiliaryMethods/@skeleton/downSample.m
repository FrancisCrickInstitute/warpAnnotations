function [ skel ] = downSample( skel,treeIdx,downsamplefactor )
% Downsample a Tree.
% INPUT treeIndex: Index (not id!) of tree in skel.(Default=all trees)
%       downsamplefactor: The factor by which degree 2 nodes would be
%       downsampled
%OUTPUT skel: Downsampled skeleton
% Author: Ali Karimi <ali.karimi@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIdx)
    treeIdx = 1:skel.numTrees();
end

for tr = treeIdx
   secondDegreeNodes =find(cell2mat(skel.calculateNodeDegree(tr))==2);
   modWithFactor=@(secondDegreeNodeID) logical(mod(secondDegreeNodeID,...
       downsamplefactor));
   nodesToDelete = secondDegreeNodes(arrayfun(modWithFactor,...
       1:length(secondDegreeNodes)));
   skel = skel.deleteNodes(tr,nodesToDelete,true);
end

end


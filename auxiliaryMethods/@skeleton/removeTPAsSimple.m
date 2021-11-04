function obj = removeTPAsSimple(obj, treeIndices)
%Remove three-point-annotations from tree by eroding all degree
% one nodes twice
%INPUT treeIndices: (Optional) [Nx1] array specifying the
%           linear indices of the trees for which to remove the
%           TPAs.
%           (Default: 1:obj.numTrees())
%
% NOTE This also erodes loose ends of a tracing and spines.
%
% Author: Manuel Berning

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:obj.numTrees();
elseif iscolumn(treeIndices)
    treeIndices = treeIndices';
end

for tr = treeIndices
    for i=1:2
        trEdges = obj.edges{tr};
        uniqueEdges = unique(trEdges(:));
        count = histc(trEdges(:),uniqueEdges);
        toDelete = uniqueEdges(count == 1);
        obj = obj.deleteNodes(tr,toDelete);
    end
end
end
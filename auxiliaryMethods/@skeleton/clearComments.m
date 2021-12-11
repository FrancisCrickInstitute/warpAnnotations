function skel = clearComments(skel, treeIndices)
%Delete all comments for the specified trees.
% INPUT treeIndices: (Optional) Linear indices of the trees in
%             skel to add to obj.
%             (Default: all trees in skel).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
elseif ~isrow(treeIndices)
    treeIndices = treeIndices';
end

for tr = treeIndices
    tmp = repmat({''},size(skel.nodes{tr},1),1);
    [skel.nodesAsStruct{tr}.comment] = tmp{:};
end
end
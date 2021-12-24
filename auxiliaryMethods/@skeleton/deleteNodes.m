function obj = deleteNodes(obj, treeIndex, indices, closeGap)
% Delete multiple nodes of a tree.
%INPUT treeIndex: int
%           Index (not id!) of tree in skel.
%      indices: [Nx1] int or logical
%           Linear or logical indices (not ids!) of multiple nodes to
%           delete.
%      closeGap: logical
%           Boolean specifying whether the neighbors of
%           the deleted node should be connected to close a
%           potential gap.
% NOTE Tree might be split after deleting nodes if closeGap is
%      set to false;
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('closeGap','var') || isempty(closeGap)
    closeGap = false;
end

if islogical(indices)
    indices = find(indices);
end

indices = sort(indices,'descend');
for i = 1:length(indices)
    obj = obj.deleteNode(treeIndex,indices(i), closeGap);
end
end
function [ nodeIdx, treeIdx ] = nodeId2Idx( skel, treeIndices )
%NODEID2IDX Get the linear index of a node given its id.
% INPUT treeIndices: (Optional) [Nx1] int or logical
%           Linear or logical indices of the trees of interest (although
%           this is typically not needed).
%           (Default: all trees)
% OUTPUT nodeIdx: [Nx1] sparse double
%           Returns the linear node index for the specified id, i.e.
%           nodeIdx(id) gives the linear index of the specified ID id.
%        treeIdx: [Nx1] sparse double
%           The tree index for the specified node id.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

idIdx = cell2mat(cellfun(@(x)[x(:,1), (1:size(x, 1))'], ...
    skel.nodesNumDataAll(treeIndices), ...
    'UniformOutput', false));
nodeIdx = sparse(idIdx(:,1), 1, idIdx(:,2), skel.largestID, 1);

if nargout == 2
    if islogical(treeIndices)
        treeIndices = find(treeIndices);
    end
    tr = cell2mat(arrayfun(@(x)x.*ones(size(skel.nodes{x}, 1), 1), ...
        treeIndices(:), 'UniformOutput', false));
    treeIdx = sparse(idIdx(:,1), 1, tr, skel.largestID, 1);
end

end


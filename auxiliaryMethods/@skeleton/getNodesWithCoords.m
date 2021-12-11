function nodeIdx = getNodesWithCoords( skel, coords, treeIndices )
%GETNODESWITHCOORDS Return the linear indices of the nodes with the
%specified coordinates.
% INPUT coords: [Nx3] int
%           Node coordinates to search for.
%       treeIndices: (Optional) [Nx1] int or logical
%           Linear or logical indices of the trees of interest.
% OUTPUT nodeIdx: [Nx1] cell
%           Each cell contains the linear indices of the found nodes for
%           one tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

nodeCoords = skel.getNodes();
l = cellfun(@(x)size(x,1), skel.nodes);
foundNodes = ismember(nodeCoords, coords, 'rows');
foundNodes = mat2cell(foundNodes,l, 1);
nodeIdx = cellfun(@find, foundNodes, 'UniformOutput', false);
nodeIdx = nodeIdx(treeIndices);

end


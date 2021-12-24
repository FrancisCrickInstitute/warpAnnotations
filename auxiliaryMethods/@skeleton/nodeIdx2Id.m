function idx2IdMap = nodeIdx2Id( skel, treeIndices )
%NODEIDX2ID Get a mapping for node indices to node ids.
% INPUT treeIndices: (Optional) [Nx1] int or logical
%           Linear or logical indices of the trees of interest.
%           (Default: all trees)
% OUTPUT idx2IdMap: [Nx1] cell of [Mx1] int
%           Mapping from linear node indices to node it for the requested
%           trees, i.e. idx2IdMap{tr}(idx) gives the id for the node with
%           index idx in tree tr.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

idx2IdMap = cellfun(@(x) x(:,1), skel.nodesNumDataAll(treeIndices), ...
    'UniformOutput', false);

end


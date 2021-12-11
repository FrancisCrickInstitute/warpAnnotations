function nodeDegree = calculateNodeDegree(obj, tree_indices)
%Calculate the node degree of each node the specified trees.
% INPUT tree_indices: (Optional) Array of integer specifying
%           the trees for which to calculate the node degrees.
%           (Default: all trees).
% OUTPUT nodeDegree: Cell array of length(tree_indices)
%           containing the node degree for each node in the
%           corresponding tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('tree_indices','var') || isempty(tree_indices)
    tree_indices = 1:length(obj.nodes);
elseif ~isrow(tree_indices)
    tree_indices = tree_indices';
end

%node degree via number of occurrences in edge list
nodeDegree = cellfun(@(x)accumarray(x(:),1), ...
    obj.edges(tree_indices),'UniformOutput',false);
end
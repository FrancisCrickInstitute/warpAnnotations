function n = numNodes( skel, trees )
%NUMNODES Get the number of nodes of a tree.
% INPUT trees: (Optional) [Nx1] int
%           Tree indices for which the number of nodes is calculated.
%           (Default: 1:skel.numTrees())
% OUTPUT n: [Nx1] int
%           Number of nodes for each tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('trees','var') || isempty(trees)
    trees = 1:skel.numTrees();
end
n = cellfun(@(x)size(x,1),skel.nodes(trees));

end


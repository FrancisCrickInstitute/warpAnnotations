function l = pathLength(obj, treeIndices,scale)
%Compute the physical path length of the specified trees.
% INPUT treeIndices:(Optional) Vector of integer specifying the
%           trees of interest.
%           (Default: all trees).
% OUTPUT l: Vector of length treeIndices containing the total
%           path length of each specified tree in nm using the
%           scale provided in skel.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
if ~exist('scale','var') || isempty(scale)
    scale =obj.scale;
end

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:length(obj.nodes);
end
l = zeros(length(treeIndices),1);
for tr = 1:length(treeIndices)
    idx = treeIndices(tr);
    if ~isempty(obj.edges{idx})
    	l(tr) = obj.physicalPathLength(obj.nodes{idx},obj.edges{idx}, scale);
    else
        l(tr) = 0;
end
end

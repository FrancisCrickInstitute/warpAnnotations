function skel = reset(skel, treeBaseName)
%Reset tree IDs and names, node IDs and node comments.
% INPUT treeBaseName: (Optional) String which is used as the
%           default name for the trees followed by the tree id.
%           (Default: 'Tree')
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeBaseName','var') || isempty(treeBaseName)
    treeBaseName = 'Tree';
end

skel = skel.resetNodeIDs();
skel = skel.resetTrees(treeBaseName);
skel = skel.clearComments();
end
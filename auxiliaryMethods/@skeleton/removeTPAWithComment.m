function skel = removeTPAWithComment( skel, comment, mode , steps)
%REMOVETPAWITHCOMMENT Remove three-point annotations with the specified
% comment.
% INPUT comment: string
%           see skeleton.getNodesWithComment
%       mode: string
%           see skeleton.getNodesWithComment
% OUTPUT skel: skeleton object
%           Skeleton object with TPAs removed.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% Modified by: Sahil Loomba <sahil.loomba@brain.mpg.de>
if ~exist('steps','var') || isempty(steps)
    steps = 1;
end

nodes = skel.getNodesWithComment(comment, [], mode);

if ~iscell(nodes)
    nodes = {nodes};
end

for tr = 1:skel.numTrees()
    toDel = find(skel.reachableNodes(tr, nodes{tr}, steps, 'up_to'));
    skel = skel.deleteNodes(tr, toDel); %#ok<FNDSB>
end

end


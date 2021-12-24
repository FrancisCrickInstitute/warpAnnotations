function skel = deleteNodesWithComment( skel, comment, mode, deleteSecondOrder )
%           Deletes all Nodes that have or contain (see mode) a specific comment.
% Input
% comment   string containing the comment which is searched for
% mode      string determining the string search (see
%           skeleton.getNodesWithComment)
% deleteSecondOrder     Boolean determining if the second node after the
%                       deleted nodes will be deleted too
%
% Author: Marcel Beining

if ~exist('mode','var') || isempty(mode)
    mode = 'exact';
end

if ~exist('deleteSecondOrder','var') || isempty(deleteSecondOrder)
    deleteSecondOrder = false;
end


nodesIdx = skel.getNodesWithComment(comment, [], mode);
if ~iscell(nodesIdx)
    nodesIdx = {nodesIdx};
end

if deleteSecondOrder
    nodesIdx = arrayfun(@(x) unique(skel.edges{x}(any(ismember(skel.edges{x},nodesIdx{x}),2),:)),1:skel.numTrees,'uni',0);
end

for i = 1:skel.numTrees
    skel = skel.deleteNodes(i,nodesIdx{i});
end

end


function obj = deleteDuplicateNodes(obj, treeIndex)
% Delete connected nodes that are at the same position of a tree.
%INPUT (optional) treeIndex: int
%           Index (not id!) of tree in skel.

% Author: Marcel Beining <marcel.beining@brain.mpg.de>
if nargin < 2
    treeIndex = numel(obj.nodes);
end
for t = 1:numel(treeIndex)
    indicesToDelete = obj.edges{treeIndex(t)}(~any(obj.nodes{treeIndex(t)}(obj.edges{treeIndex(t)}(:,1),:)-obj.nodes{treeIndex(t)}(obj.edges{treeIndex(t)}(:,2),:),2),:);
    
    indicesToDelete = sort(indicesToDelete(:,2),'descend');
    for i = 1:length(indicesToDelete)
        obj = obj.deleteNode(treeIndex(t),indicesToDelete(i), 1); % delete duplicate nodes and close gaps
    end
end
end
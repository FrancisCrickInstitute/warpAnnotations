function obj = removeUnconnectedNodes(obj)
% Remove all nodes that are not connected to any edge anymore

for treeIndex=1:length(obj.nodes)
    nodesToRemove = sort(setdiff(1:size(obj.nodes{treeIndex},1), unique(obj.edges{treeIndex}(:))), 'descend');
    obj = obj.deleteNodes(treeIndex, nodesToRemove, 0);
end

end


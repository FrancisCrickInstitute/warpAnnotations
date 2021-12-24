function edgesUpdated = extractEdgeList(obj,treeIndex,indices)
% Input: 
%       obj: skeleton object
%       treeIndex: index of tree whose nodes are extracted
%       indices: Logical indices of the nodes to extract
% Output;
%       edgesUpdated : udpated edgeList corresponding to the nodes to be extract
% By: 
%         Sahil Loomba <sahil.loomba@brain.mpg.de>
indicesKeep = find(indices);
indicesDel = find(~indices);

edges = obj.edges{treeIndex};

idxEdgesToKeep = ismember(edges(:,1),indicesKeep) & ismember(edges(:,2),indicesKeep);
edgesUpdated = edges(idxEdgesToKeep,:);

toDel = arrayfun(@(x) sum(indicesDel<x),1:numel(indices)); toDel = toDel(:);

edgesUpdated = reshape(edgesUpdated(:) - toDel(edgesUpdated(:)),size(edgesUpdated));

end
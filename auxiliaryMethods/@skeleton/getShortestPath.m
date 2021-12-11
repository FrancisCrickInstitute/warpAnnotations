function [path, treeIdx, l] = getShortestPath(skel, startID, endID)
%Calculate the shortest path between two nodes in a tree.
% INPUT startID: The ID of the startNode.
%       endID: The ID of the end node.
% OUTPUT path: Vector of integer containing the linear indices
%              of nodes along the path. startNode and endNode
%              are the first and last node in path.
%        treeIdx: The index of the tree containing the ids.
%        l: The length of the shortest path between the IDs in
%           nm.
%
% NOTE This function uses the scale saved in skel.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[treeIdx, nodeIdx] = skel.getNodesWithIDs([startID, endID]);

if length(unique(treeIdx)) ~= 1
    error('Nodes are not in the same tree')
elseif any(nodeIdx == 0)
    error('Node id %d was not found', find(nodeIdx == 0,1));
end
treeIdx = unique(treeIdx);
adjM = skel.createAdjacencyMatrix(treeIdx,1); % get distance weighted adjacency matrix

[~, path] = graphshortestpath(adjM, nodeIdx(1), nodeIdx(2));
if nargout > 2
    l = skel.physicalPathLength(skel.nodes{treeIdx}(path,1:3),[],skel.scale);
end
end
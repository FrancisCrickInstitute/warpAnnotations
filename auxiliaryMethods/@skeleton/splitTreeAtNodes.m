function skel = splitTreeAtNodes(skel, nodeIds, keepNodes)
% Split a tree into connected components by removing a specified node or
% all edges at a specified node.
% INPUT nodeIds: int
%           The ids of the node at which the tree is split.
%        keepNodes: (Optional) logical
%           Nodes are kept in all resulting split trees.
%           (Default: false)
% OUTPUT skel: skeleton object
%           Updated skeleton object where each connected component of
%           the split tree is added as an additional tree.
% 
% Note
%   This operation preserves the placement and connectivity of nodes.
%   But additional informations (e.g., branchpoint markers, tree colors,
%   comments, etc.) are lost.

if ~exist('keepNodes','var') || isempty(keepNodes)
    keepNode = false;
end

% get tree and node indices
[treeIdxs, nodeIdxs] = skel.getNodesWithIDs(nodeIds);
assert(all(treeIdxs > 0) && all(nodeIdxs > 0) && length(unique(treeIdxs)) == 1);
treeIdx = unique(treeIdxs);

% find all edges involving the given nodes
name  = skel.names{treeIdx};
nodes = skel.nodes{treeIdx};
edges = sort(skel.edges{treeIdx}, 2);
edgeMask = any(ismember(edges, nodeIdxs), 2);

% find connected components
maxIdx = max(edges(:));
assert(all(diff(edges, 1, 2) >= 0));

cleanEdges = edges(~edgeMask, :);

% build adjacency matrix
graph = sparse( cleanEdges(:, 2), cleanEdges(:, 1), ...
    ones(size(cleanEdges, 1), 1), maxIdx, maxIdx);

% identify connected components
[compCount, compIds] = graphconncomp( ...
    graph, 'Directed', false, 'Weak', false);

%remove single node components from removed nodes
compCount = compCount - length(nodeIdxs);
for i=1:length(nodeIdxs)
	compIds(compIds > compIds(nodeIdxs(i))) = compIds(compIds > compIds(nodeIdxs(i))) - 1;
	compIds(nodeIdxs(i)) = 0;
end

for curIdx = 1:compCount
    curNodes = find(compIds == curIdx);

    if keepNodes
        nodeEdgeMask = any(ismember(edges, curNodes), 2) & any(ismember(edges, nodeIdxs), 2);
        edgeEdgeMask = edges(nodeEdgeMask, :);
        nodes2add = edgeEdgeMask(ismember(edgeEdgeMask, nodeIdxs));
        curNodes = sort([curNodes(:); nodes2add]);
    end
    
    curEdgeMask = all(ismember(edges, curNodes), 2);
    curEdges = edges(curEdgeMask, :);
    
    % renumber edges
    [~, curEdgesNew] = ismember(curEdges, curNodes);
    curNodesNew = nodes(curNodes, :);
    
    % adding new tree
    curName = [ ...
        name, ' Part #', num2str(curIdx)];
    skel = skel.addTree( ...
        curName, curNodesNew, curEdgesNew);
end

% remove old tree
skel = skel.deleteTrees(treeIdx);

end

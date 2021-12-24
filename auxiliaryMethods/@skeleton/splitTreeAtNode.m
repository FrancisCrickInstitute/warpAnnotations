function skel = splitTreeAtNode(skel, nodeId, keepNode)
% Split a tree into connected components by removing a specified node or
% all edges at a specified node.
% INPUT nodeId: int
%           The id of the node at which the tree is split.
%        keepNode: (Optional) logical
%           The node with nodeId is kept in all resulting split trees.
%           (Default: false)
% OUTPUT skel: skeleton object
%           Updated skeleton object where each connected component of
%           the split tree is added as an additional tree.
% 
% Note
%   This operation preserves the placement and connectivity of nodes.
%   But additional informations (e.g., branchpoint markers, tree colors,
%   comments, etc.) are lost.
%
% Written by
%   Alessandro Motta <alessandro.motta@brain.mpg.de>
%   Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('keepNode','var') || isempty(keepNode)
    keepNode = false;
end

% get tree and node indices
[treeIdx, nodeIdx] = skel.getNodesWithIDs(nodeId);
assert(treeIdx > 0 && nodeIdx > 0);

% find all edges involving the given node
name  = skel.names{treeIdx};
nodes = skel.nodes{treeIdx};
edges = skel.edges{treeIdx};
edgeMask = any(edges == nodeIdx, 2);

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

%remove single node component from removed node
compCount = compCount - 1;
compIds(compIds > compIds(nodeIdx)) = ...
    compIds(compIds > compIds(nodeIdx)) - 1;
compIds(nodeIdx) = 0;

for curIdx = 1:compCount
    curNodes = find(compIds == curIdx);

    if keepNode
        curNodes = sort([curNodes(:); nodeIdx]);
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

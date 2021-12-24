function skel = directedEdgeList( skel, treeIdx, nodeIdx )
%DIRECTEDGELIST Direct the edge list away from a starting node.
% INPUT treeIdx: int
%           Index of the tree of interest.
%       nodeIdx: int
%           Index of a node of the respective tree. The edges will be
%           directed along the shortest path from this tree to any other
%           node.
% OUTPUT skel: skeleton object
%           The skeleton object with the directed edge list for the
%           corresponding tree.
%
% NOTE If a tree is not a connected component than this function discards
%      all edges in the components without the nodeIdx node.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

G = skel.getGraph(treeIdx, false);
tr = shortestpathtree(G, nodeIdx);
skel.edges{treeIdx} = tr.Edges.EndNodes;

end


function allPaths = getShortestPaths(skel, treeIdx)
% allPaths = skel.getShortestPaths(treeIdx)
%   Computes the length of the shortest path between each pair
%   of nodes in the tree specified by treeIdx.
%
% treeIdx
%   Scalar. Linear index of tree.
%
% allPaths
%   Sparse and symmetric NxN matrix. Entry allPaths(i, j) is
%   the length of the shortest path between node i and j in
%   nano-metres.
%
% NOTE
%   This method uses the Skeleton object's scale property to
%   convert the node distance into physical units.
%
% Written by
%   Alessandro Motta <alessandro.motta@brain.mpg.de>

distMat = skel.createDistanceMatrix(treeIdx);
allPaths = graphallshortestpaths(distMat, 'Directed', false);
end
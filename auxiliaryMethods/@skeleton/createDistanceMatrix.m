function distMat = createDistanceMatrix(obj, treeIdx)
% distMat = createDistanceMatrix(obj, treeIdx)
%   Computes the symmetric and sparse distance matrix for
%   all neighbouring nodes in the tree with index 'treeIdx'.
%   Distances are in nanometer. The diagonals is zero and so
%   are the distances between non-neighbouring nodes.
%
% WARNING
%   Make sure that the scale was set correctly!
%
% Written by
%   Alessandro Motta <alessandro.motta@brain.mpg.de>

% load coordinates of nodes
treeNodes = obj.nodes{treeIdx};
treeNodes = treeNodes(:, 1:3);
nodeCount = size(treeNodes, 1);

% load edges
treeEdges = obj.edges{treeIdx};

% compute pair-wise distance
edgeDiffs = treeNodes(treeEdges(:,1),:) ...
    - treeNodes(treeEdges(:,2),:);
edgeDiffs = bsxfun( ...
    @times, edgeDiffs, obj.scale(:)');
edgeLens = sqrt(sum(edgeDiffs .^ 2, 2));

% build output
distMat = sparse( ...
    treeEdges(:, 1)', treeEdges(:, 2)', ...
    edgeLens(:)', nodeCount, nodeCount);

% make symmetric
distMat = distMat + distMat';
end
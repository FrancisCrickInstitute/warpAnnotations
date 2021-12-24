function am=createAdjacencyMatrix(obj,treeIdx,distWeighted)
%Create the adjacency matrix of a tree of the Skeleton.
% INPUT treeIdx: Integer index of the tree in obj to create
%           the adjacency matrix for.
%       distWeighted: Boolean (DEFAULT 0) to specify if matrix is logical
%                     or contains the physical distance information between
%                     the edges
% OUTPUT am: Sparse, rectangular and symmatric matrix,
%           where am(i,j) = am(j,i) =  1 (or Lij), if node i and node j
%           are connected.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('distWeighted','var') || isempty(distWeighted)
    distWeighted = false;
end

numNodes = size(obj.nodes{treeIdx}, 1);

if numNodes > 1
    edgesInTree = obj.edges{treeIdx};
    edgeCount = size(edgesInTree, 1);
    if distWeighted
        [~,edgeVec] = obj.physicalPathLength(obj.nodes{treeIdx}, obj.edges{treeIdx}, obj.scale);
    else
        edgeVec = true(1, edgeCount);
    end
    % make sure even nodes at the exact same location have a finite distance associated with them
    edgeVec(edgeVec == 0) = realmin;
    % build adjacency matrix
    am = sparse( ...
        edgesInTree(:, 1)', edgesInTree(:, 2)', ...
        edgeVec, numNodes, numNodes);
    
    % make symmetric
    am = am + am';
else
    % single node case
    am = zeros(1);
end
end

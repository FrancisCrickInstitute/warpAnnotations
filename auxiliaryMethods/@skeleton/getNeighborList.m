function neighborList = getNeighborList(obj, treeIdx)
%Returns a list of neighbors of each node in a tree.
% INPUT treeIdx: Index of the tree of interest in obj.
% OUTPUT neighborList: Cell array of length number of nodes in
%           tree with treeIdx. Each cell contains the indices
%           of the neighbors of the corresponding node.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

neighborList = cell(size(obj.nodes{treeIdx},1),1);
trEdges = obj.edges{treeIdx};
for i = 1:size(trEdges,1)
    n1 = trEdges(i,1);
    n2 = trEdges(i,2);
    neighborList{n1} = [neighborList{n1}, n2];
    neighborList{n2} = [neighborList{n2}, n1];
end
end
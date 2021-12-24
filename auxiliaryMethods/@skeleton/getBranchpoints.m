function branchpoints = getBranchpoints(obj, treeIdx)
%Returns a list of branchpoints contained in the tree.
% INPUT     treeIdx: Index of the tree of interest in obj.
% OUTPUT    branchpoints: branchpoints (as node idx)

edges = obj.edges{treeIdx};
biEdges = [edges; fliplr(edges)];
leftEdges = biEdges(:,1);
binvec = min(leftEdges):1:max(leftEdges)+1;
hTemp = histc(leftEdges, binvec);
bpTemp = find(hTemp>2);
branchpoints = binvec(bpTemp)';

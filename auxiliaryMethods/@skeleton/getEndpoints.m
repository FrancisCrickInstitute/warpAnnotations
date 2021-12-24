function endpoints = getEndpoints(obj, treeIdx)
%Returns a list of endpoints contained in the tree.
% INPUT     treeIdx: Index of the tree of interest in obj.
% OUTPUT    endpoints: endpoints (as node idx)

edges = obj.edges{treeIdx};
biEdges = [edges; fliplr(edges)];
leftEdges = biEdges(:,1);
binvec = min(leftEdges):1:max(leftEdges)+1;
hTemp = histc(leftEdges, binvec);
epTemp = hTemp==1;
endpoints = binvec(epTemp)';

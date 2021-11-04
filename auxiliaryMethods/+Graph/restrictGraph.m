function edges = restrictGraph(edgesOrAdjM, nodes, numNeighbors)
%RESTRICTGRAPH Restrict graph to a set of nodes including their neighbors and
% optionally higher order neighbors (number given by numNeighbors)

%   INPUT
%     edgesOrAdjM: [Nx2] array of integers (edges) or sparse adjacency matrix.
%     nodes: Vector containing the IDs of nodes to which the graph shall be
%            restricted.
%     numNeighbors: (Optional) Integer specifying a maximum distance from
%            nodes in the graph. Only nodes within this distance are kept.
%            (Default: 0)
%
%   OUTPUT
%     edges: [Nx2] array of integers specifying all edges in reduced graph.
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  % NOTE: Implementation adapted from Seg.Global.loadSupervoxelGraph
  %       by Benedikt Staffler <benedikt.staffler@brain.mpg.de>

  if ~exist('numNeighbors','var') || isempty(numNeighbors)
      numNeighbors = 0;
  end
  
  if numNeighbors == 0 || ~issparse(edgesOrAdjM)
      %computationally usually more effective
      toKeep = all(ismember(edgesOrAdjM,nodes),2);
      edges = edgesOrAdjM(toKeep,:);
      return
  end
  
  if ~issparse(edgesOrAdjM)
    adjM = Graph.edges2Adj(edgesOrAdjM);
  else
    adjM = edgesOrAdjM;
  end
  
  nodes = double(nodes);
  nodes = sparse(nodes, ones(length(nodes),1), ...
    ones(length(nodes),1), size(adjM,1),1);

  for i = 1:numNeighbors
      nodes = adjM*nodes + nodes;
  end

  nodes = find(nodes);
  adjM = adjM(nodes, nodes);
  edges = Graph.adj2Edges(adjM);
  edges = nodes(edges);

end

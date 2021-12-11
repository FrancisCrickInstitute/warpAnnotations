function edges = deleteNodes(edges, nodesToDel, safeMode)
%DELETENODES Delete nodes from graph while optionally bridging the gaps.
%
%   INPUT
%     edges: [Nx2] array of integers specifying all edges in graph.
%     nodesToDel: Vector containing the IDs of nodes to be deleted.
%     safeMode: (Optional) Boolean. Connect the neighboring nodes of deleted
%       nodes (true) or allow splitting of the graph (false) (Default: true)
%
%   OUTPUT
%     edges: [Nx2] array of integers specifying all edges in graph.
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  if ~exist('safeMode', 'var') || isempty(safeMode)
    safeMode = true;
  end

  % If safeMode: Find and connect all neighbors of nodes to be deleted
  if safeMode
    for i=1:length(nodesToDel)
      neighborNodes = findNeighbors(nodesToDel(i), edges);
      %newEdges = allEdges(neighborNodes);
      newEdges = simpleHamiltonianPath(neighborNodes);
      edges = vertcat(edges, newEdges);
    end
  end

  % Delete edges from graph that contain node to be deleted
  edges = deleteEdges(edges, nodesToDel);

end

function neighborNodes = findNeighbors(node, edges)
  % Find all edges in edge list which contain node.
  idx = any(edges == node, 2);
  nodeEdges = edges(idx, :);
  neighborNodes = setdiff(nodeEdges, node);
end

function edges = allEdges(nodes)
  % Find all possible edges between given nodes.
  if(isempty(nodes) || length(nodes) < 2)
    edges = [];
  else
    perm = permn(nodes, 2); % see utils/permn/permn.m
    edges = unique(sort(perm, 2), 'rows');
  end
end

function edges = deleteEdges(edges, nodes)
  % Delete all edges that contain one or more of the given nodes.
  idx = find(any(ismember(edges, nodes), 2));
  edges(idx, :) = [];
end

function edges = simpleHamiltonianPath(nodes)
  % Get a simple Hamiltonian path by connecting nodes in order of occurence
  edges = [];
  for i = 1:length(nodes)-1
    edges = [edges; nodes(i) nodes(i+1)];
  end
end

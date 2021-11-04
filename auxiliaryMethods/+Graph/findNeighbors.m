function [neighborNodes, neighborIdx]  = findNeighbors(node, edges)
%NEIGHBORNODES Find all neighbors of a given node.
%
%   INPUT
%     node: integer.
%     edges: [Nx2] array of integers specifying all edges in graph.
%
%   OUTPUT
%     neighborNodes: [Nx1] vector of integers.
%     neighborIdx: [Nx1] vector containing the linear indices of the the
%                  neighborNodes in edges.
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  idx = any(edges == node, 2);
  nodeEdges = edges(idx, :);
  if nargout == 1
    %only do this for one output since setdiff deletes repetitions
    neighborNodes = setdiff(nodeEdges, node);
  else
    %keep all found neighbors
    toDel = ismember(nodeEdges,node)';
    nodeEdges = nodeEdges';
    neighborNodes = nodeEdges(~toDel);
  end
  neighborIdx = find(idx);

end

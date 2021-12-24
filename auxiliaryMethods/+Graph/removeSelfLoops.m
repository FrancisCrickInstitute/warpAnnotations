function edges = removeSelfLoops(edges)
%REMOVESELFLOOPS Delete edges in graph that start and end in the same node.
%
%   INPUT
%     edges: [Nx2] array of integers specifying all edges in graph.
%
%   OUTPUT
%     edges: [Nx2] array of integers specifying all edges in graph.
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  idx = edges(:,1) == edges(:,2);
  edges(idx, :) = [];

end

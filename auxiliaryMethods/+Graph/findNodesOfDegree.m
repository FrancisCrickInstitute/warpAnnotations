function nodes = findNodesOfDegree(edges, degree)
%FINDNODESOFDEGREE Find nodes of speicific node degree in graph defined by
%edge list.
%
%   INPUT
%     edges: [Nx2], graph (list of edges).
%     degree: degree of nodes to be found (e.g. degree = 3 for branch points).
%
%   OUTPUT
%     nodes: [Nx1], list of nodes with degree "degree".
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  % Flatten graph
  flatGraph = reshape(edges, numel(edges), 1);

  % Calculate node degree
  vals = 1:max(flatGraph);
  deg = histc(flatGraph, vals);

  nodes = vals(deg == degree);

end

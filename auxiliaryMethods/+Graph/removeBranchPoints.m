function edges = removeBranchPoints(edges)
%REMOVEBRANCHPOINTS Remove branch points from graph (i.e. edges that contain
%values that occur more than 2 times in the full graph)
%
%   INPUT
%     edges: [Nx2], graph (list of edges)
%
%   OUTPUT
%     edges: [Nx2], graph witout branch points
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  % Flatten graph
  flatGraph = reshape(edges, numel(edges), 1);

  % Calculate node degree
  vals = 1:max(flatGraph);
  degree = histc(flatGraph, vals);

  % Find branch points (node degree > 2)
  toDelete = vals(degree > 2);
  del = ismember(edges, toDelete);

  % Delete branch points
  edges(del(:,1), :) = [];
  del(del(:,1), :) = [];
  edges(del(:,2), :) = [];

end

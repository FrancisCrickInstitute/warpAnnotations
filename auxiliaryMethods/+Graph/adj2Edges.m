function [ edges, weights ] = adj2Edges( adjM )
%ADJ2EDGES Create the edge list from an adjacency matrix.
% INPUT adjM: Sparse symmetric adjacency matrix.
% OUTPUT edges: [Nx2] list of integer containing the edges of the graph.
%        weights: [Nx1] list of weights for the corresponding edges.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

idx = find(tril(adjM));
[y,x] = ind2sub(size(adjM),idx);
edges = [x(:),y(:)];

m = max([x;y]);
if m < intmax('uint16')
    edges = uint16(edges);
elseif m < intmax('uint32')
    edges = uint32(edges);
end

if nargout == 2
    weights = full(adjM(idx));
end

% Sanity check
assert(size(edges, 2) == 2);
end

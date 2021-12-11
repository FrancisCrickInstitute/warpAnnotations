function adjM = edges2Adj( edges, weights, fun, triangular, symmetric )
%EDGE2ADJ Create sparse adjacency matrix from edge list.
% INPUT edges: [Nx2] array of integer specifying the edges of an undirected
%              graph.
%       weights: (Optional) [Nx1] array of double specifying the edge
%               weights.
%       fun: (Optional) Function handle which is used to combine the
%             multiple edges between the same nodes.
%            (Default: @max)
%       triangular: (Optional) Only keep upper triangular part of adj matrix
%            before symmetrization.
%            (Default: false)
%       symmetric: (Optional) Option for symmetric (true) or anti-symmetric
%            output (false)
%            (Default: true)
% OUTPUT adjM: Sparse symmetric adjacency matrix.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% 03 Nov 2015: Added optional weights argument
%              (Thomas Kipf <thomas.kipf@brain.mpg.de>)

if ~exist('fun','var')  || isempty(fun)
    fun = @max;
end
if ~exist('symmetric','var')  || isempty(symmetric)
    symmetric = true;
end
if ~exist('triangular','var')  || isempty(triangular)
    triangular = false;
end

[edges,~,ic] = unique(edges,'rows');
edges = double(edges);
numNodes = max(edges(:));
if ~exist('weights','var') || isempty(weights)
    adjM = sparse(edges(:,1),edges(:,2),true(1,length(edges(:,1))),numNodes,numNodes);
else
    weights = accumarray(ic,weights,[],fun);
    adjM = sparse(edges(:,1),edges(:,2),weights,numNodes,numNodes);
end
if triangular
  adjM = triu(adjM);
end
if symmetric
  adjM = adjM + adjM';
else
  adjM = adjM - adjM';
end

end

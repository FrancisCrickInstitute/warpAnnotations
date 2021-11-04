function [nIds, nIdx] = edges2Neighbors(edges)
%EDGES2NEIGHBORS Calculate neighbors from edges.
% INPUT edges: [Nx2] int
%           Each row defines an undirected edges between
%           the corresponding vertex idx.
% OUTPUT nIds: [Nx1] cell
%           Each cell contains the vertex ids of all
%           neighboring vertices.
%        nIdx: [Nx1] cell
%           Contains the edge index for the corresponding neighbor id in
%           nIds.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

n1 = size(edges, 1);
edges = edges(:);
numNeigh = accumarray(edges, 1);
[~, idx] = sort(edges);
isInFirstRow = idx <= n1;
idx(~isInFirstRow) = idx(~isInFirstRow) - n1;
if nargout > 1
    nIdx = mat2cell(idx, numNeigh, 1);
end
idx(isInFirstRow) = idx(isInFirstRow) + n1;
nIds = edges(idx);
nIds = mat2cell(nIds, numNeigh, 1);
end

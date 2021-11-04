function [l,nL] = physicalPathLength(nodes, edges, voxelSize)
% Calculate the physical path length of a graph.
% INPUT nodes: [Nx3] array containing the coordinates of nodes.
%              Additional rows in nodes will be discarded.
%       edges: (Optional) [Nx2] array of integer. Each row defines
%              an edge between the corresponding nodes in
%              nodes.
%              (Default: If [] or empty it will be assumed that
%              the nodes form a chained from the first to the
%              last node.)
%       voxelSize: (Optional) The physical size of voxels for the
%              specified coordinates of nodes.
%              (Default: [1, 1, 1]);
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

nodes = double(nodes);

if ~exist('edges','var') || isempty(edges)
    edges = [(1:size(nodes,1) - 1)',(2:size(nodes,1))'];
end

if ~exist('voxelSize','var') || isempty(voxelSize)
    voxelSize = [1, 1, 1];
end
if isempty(nodes)
    l = 0;
    nL = 0;
else
    cartesianEdges = nodes(edges(:, 1), 1 : 3) - nodes(edges(:, 2), 1 : 3);
    scaledEdges = bsxfun(@times, double(cartesianEdges), voxelSize);
    nL = sqrt(sum(scaledEdges .^ 2, 2));
    l = sum(nL);
end
end
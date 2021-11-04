function skel = fromMST(nodes, voxelSize, skel)
%FROMMST Skeleton from the minimal spanning tree of a set of nodes weighted
%by their distance.
% INPUT nodes: [Nx3] double or [Nx1] cell array of [Nx3] double
%           Node coordinates (x, y, z) or cell array of coordinates. Each
%           cell will be saved to a separate tree.
%       voxelSize: [1x3] double. Physical size of voxel along X, Y and Z.
%       skel: (Optional) skeleton object
%           Adds the new trees to the input skeleton object instead of
%           creating a new one.
%           (Default: new skeleton object is created)
% OUTPUT skel: skeleton object
%           Skeleton object
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~iscell(nodes)
    nodes = {nodes};
end

if ~exist('voxelSize', 'var') || isempty(voxelSize)
    % for backward compatibility
    voxelSize = ones(1, 3);
end

if ~exist('skel', 'var') || isempty(skel)
    skel = skeleton();
end

for i = 1:length(nodes)
    curNodes = double(nodes{i});
    curNodesInNm = bsxfun(@times, curNodes, voxelSize);
    
    % determine edges (using MST on pysical distances)
    if size(curNodes, 1) > 1
        tr = graphminspantree(sparse(squareform(pdist(curNodesInNm))));
        edges = Graph.adj2Edges(tr);

        % build skeleton (using voxel coordinates)
        skel = skel.addTree([], round(curNodes), edges);
    else
        skel = skel.addTree([], round(curNodes));
    end
end

end


function edges = loadSupervoxelGraph( p, segCubeIdx, segIDs, numNeighbors, mapping )
%LOADPARTIALGRAPH Loading of the (partial) supervoxel graph.
% Load the edges of the supervoxel graph for the specified cubes.
% Optionally, the supervoxel graph can further be reduced by only
% considering segments with a maximum distance to a set of segments of
% interest.
% INPUT p: Segmentation parameter struct.
%       segCubeIdx: The indices of the cube in p.local to load.
%       segIDs: (Optional) Integer list of global segment IDs of interest.
%               (Default: All segments in all specified seg cubes)
%       numNeighbors: (Optional) Integer specifying a maximum distance from
%               segIDs in the supervoxel graph. Only segments within this
%               distance is kept. This argument requires segIDs to be not
%               empty, otherwise it can be ignored.
%       mapping: (Optional) The correspondence mapping (see
%                Seg.Global.getGLobalMapping).
%                (Default: no mapping. Not that all cubes segmentation
%                cubes are independent in this case).
% OUTPUT edges: The edges list of the supervoxel graph. Node IDs are the
%               global IDs with mapped correspondences.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% 29 Oct 2015: Moved graph restriction to separate function
%              (Thomas Kipf <thomas.kipf@brain.mpg.de>)

if ~exist('mapping','var') || isempty(mapping)
    mapping = @(x)x;
end
edges = Seg.Global.getGlobalEdges( p, segCubeIdx );
edges = mapping(edges);
edges = unique(edges,'rows');

if exist('segIDs','var') && ~isempty(segIDs)
    segIDs = double(mapping(segIDs));
    edges = Graph.restrictGraph(edges, segIDs, numNeighbors);
end

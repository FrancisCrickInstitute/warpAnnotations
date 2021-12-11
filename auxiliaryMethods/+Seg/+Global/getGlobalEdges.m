function [edges, maxEdgeIdx] = getGlobalEdges( p, segCubeIdx )
%GETGLOBALEDGES Load edges for the global segment IDs.
% INPUT p: Segmentation parameter struct.
%       segCubeIdx: (Optional) Integer vector of segmentation cube linear
%                   indices for which the edge list is loaded.
%                   (Default: All cubes in p.local)
% OUTPUT edges: [Nx2] array of uint32 containing the edges for the
%               global segment IDs.
%        maxEdgeIdxInLocalCube: [Nx1] of int where N = length(segCubeIdx)
%           containing the maximum linear index of edges in the respective
%           segCube.
%
% NOTE This does not take segment correspondences between local cubes into
%      account.
% NOTE This function currently assumes that the edges are already saved
%      with global indices in the local cubes.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('segCubeIdx','var') || isempty(segCubeIdx)
    segCubeIdx = 1:numel(p.local);
elseif iscolumn(segCubeIdx)
    segCubeIdx = segCubeIdx';
end

%load edges
edges = cell(length(segCubeIdx),1);
maxEdgeIdx = zeros(length(segCubeIdx) + 1,1);
for i = 1:length(segCubeIdx)
    m = load(p.local(segCubeIdx(i)).edgeFile);
    edges{i} = m.edges;
    maxEdgeIdx(i+1) = maxEdgeIdx(i) + size(m.edges,1);
end
edges = cell2mat(edges);
maxEdgeIdx(1) = [];

end

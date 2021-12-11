function segIds = mergeConnComp(segIds, edges)
%MERGECONNCOMP Add all segments to segIds that are in the same connected
% component of the graph defined by edges.
% INPUT segIds: [Nx1] cell
%           Cell array of [Nx1] int segment ids. Single cells will be
%           considered separately.
%       edges: [Nx2] int
%           Edge list of segment that belong together.
% OUTPUT segIds: [Nx1] cell
%           The input segment id cell array with all additional
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[comps, seg2comp] = Graph.findConnectedComponents(edges);
for i = 1:length(segIds)
    curComps = seg2comp(segIds{i}(segIds{i} > 0));
    curComps = unique(curComps);
    segIds{i} = unique([segIds{i}; cell2mat(comps(curComps))]);
end
end

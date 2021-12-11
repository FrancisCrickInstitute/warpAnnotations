function saveGlobalEdgeIdx( p )
%SAVEGLOBALEDGEIDX Saves a new matfile containing the linear index of the
%first edge of the local edge file in the global supervoxel graph edge
%list. The global edge index is saved in the file 'edgeGlobalIdx.mat'.
% INPUT p: A segmentation parameter struct.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

firstEdgeIdx = 1;
for i = 1:numel(p.local)
    m = matfile([p.local(i).saveFolder, 'edgeGlobalIdx.mat'],'Writable',true);
    m.firstEdgeGlobalIdx = firstEdgeIdx;
    m = load(p.local(i).edgeFile);
    firstEdgeIdx = firstEdgeIdx + size(m.edges,1);
end

end


function [segmentPCA, covMat] = getGlobalSegmentPCA( p, cluster )
%GETGLOBALSEGMENTPCA Wrapper for the segmentPCA calculation.
% INPUT p: struct
%           Segmentation parameter struct.
% OUTPUT segmentPCA: [Nx12] double
%           see Seg.Local.segmentPCA
%        covMat: [Nx12] double
%           see Seg.Local.segmentPCA
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('cluster', 'var')
    cluster = [];
end

inputCell = arrayfun(@(i){p, i}, 1:numel(p.local), 'UniformOutput', false);
job = Cluster.startJob(@jobWrapper, inputCell(:), 'numOutputs', 2, ...
    'cluster', cluster);
fprintf('[%s] Seg.Global.getGlobalSegmentPCA - Waiting for job %d.\n', ...
    datestr(now), job.Id);
wait(job);
out = fetchOutputs(job);
segmentPCA = cell2mat(out(:,1));
covMat = cell2mat(out(:,2));

end

function [segmentPCA, covMat] = jobWrapper(p, idx)
m = load(p.local(idx).segmentFile);
segPixelIdx = {m.segments.PixelIdxList};
cubeSize = diff(p.local(1).bboxSmall, [], 2) + 1;
voxelSize = p.raw.voxelSize;
[segmentPCA, covMat] = Seg.Local.segmentPCA(segPixelIdx, cubeSize, ...
    voxelSize); 
end

function area = physicalBorderArea(p)
%PHXSICALBORDERAREA Calculate the physical border area for all borders.
% INPUT p: struct
%           Segmentation parameter struct.
% OUTPUT area: [Nx1] double
%           Border area in um^2. The voxel scale is taken from
%           p.raw.voxelSize.
%
% see also Seg.Local.physicalBorderArea
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

Util.log('Submitting job to cluster.');
cluster = Cluster.getCluster('-l h_vmem=16G,h_rt=100:00:00,s_rt=99:59:30 -R y');
inputCell = cell(numel(p.local), 1);
for i = 1:numel(p.local)
    tileSize = diff(p.local(cubeIdx).bboxSmall, [], 2) + 1;
    inputCell{i} = {p.local(i).borderFile, p.raw.voxelSize, ...
        tileSize(:)'};
end

job = createJob(cluster);
job.AutoAttachFiles = true;

createTask(job,@jobWrapperPhysicalBorderArea, 1, inputCell, ...
    'CaptureDiary', true);
submit(job);
Util.log('Waiting for job %d output.', job.Id);
wait(job);
Util.log('Fetching job %d output.', job.Id);
out = fetchOutputs(job);
area = cell2mat(out);
end

function area = jobWrapperPhysicalBorderArea(borderFile, voxelSize, tileSize)
m = load(borderFile);
tileSize = tileSize(:)';
area = Seg.Local.physicalBorderArea(m.borders, voxelSize, tileSize);
end

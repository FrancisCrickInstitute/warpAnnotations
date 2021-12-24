function [area,area2] = physicalBorderAreas(param)
    % PHYSICALBORDERAREAS
    %   Computes the physical contact area (in um²) for each
    %   border in the entire data set. For more information
    %   check out Seg.Local.physicalBorderArea and
    %   Seg.Local.physicalBorderArea2
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    % Modified by
    %   Sahil Loomba <sahil.loomba@brain.mpg.de>
    cubes = param.local;
    cubeCount = numel(cubes);

    % prepare cluster
    cluster = Cluster.config( ...
        'priority', 0, ...
        'memory', 12, ...
        'time', '0:10:00');

    % create job
    job = createJob(cluster);
    job.Name = mfilename();

    % task parameters
    paramFile = fullfile(param.saveFolder, 'allParameter.mat');
    taskParams = arrayfun(@(i){paramFile, i}, 1:cubeCount, 'uni', 0);

    % create tasks
    createTask(job, @jobMain, 2, taskParams);

    % submit and wait
    submit(job);
    wait(job);

    % build output
    out = fetchOutputs(job);
    area = vertcat(out{:,1});
    area2 = vertcat(out{:,2});
end

function [area,area2] = jobMain(paramFile, cubeIdx)
    m = load(paramFile);
    param = m.p;
    cubes = param.local;
    cubeParams = cubes(cubeIdx);

    cubeBox = cubeParams.bboxSmall;
    voxelSize = param.raw.voxelSize;
    tileSize = diff(param.local(cubeIdx).bboxSmall, [], 2) + 1;
    tileSize = tileSize(:)';

    % load edges and borders
    m = load(cubeParams.borderFile, 'borders');
    borders = m.borders;
    m = load(cubeParams.edgeFile, 'edges');
    edges = m.edges;

    % load segmentation data
    seg = loadSegDataGlobal(param.seg, cubeBox);

    % run main function
    area = Seg.Local.physicalBorderArea(borders,voxelSize,tileSize);

    area2 = Seg.Local.physicalBorderArea2( ...
        borders, edges, seg, voxelSize);
 
end

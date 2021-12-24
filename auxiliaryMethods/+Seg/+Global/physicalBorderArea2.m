function area = physicalBorderArea2(param)
    % PHYSICALBORDERAREA2
    %   Computes the physical contact area (in um²) for each
    %   border in the entire data set. For more information
    %   check out Seg.Local.physicalBorderArea2
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    cubes = param.local;
    cubeCount = numel(cubes);

    % prepare cluster
    cluster = Cluster.getCluster( ...
        '-p -250', ...
        '-pe openmp 1', ...
        '-l h_vmem=12G', ...
        '-l s_rt=1:09:30', ...
        '-l h_rt=1:10:00',...
	'-tc 150');

    % create job
    job = createJob(cluster);
    job.Name = mfilename();

    % task parameters
    paramFile = fullfile(param.saveFolder, 'allParameter.mat');
    taskParams = arrayfun(@(i){paramFile, i}, 1:cubeCount, 'uni', 0);

    % create tasks
    createTask(job, @jobMain, 1, taskParams);

    % submit and wait
    submit(job);
    Cluster.waitForJob(job);

    % build output
    out = fetchOutputs(job);
    area = vertcat(out{:});
end

function area = jobMain(paramFile, cubeIdx)
    m = load(paramFile);
    param = m.p;
    cubes = param.local;
    cubeParams = cubes(cubeIdx);

    cubeBox = cubeParams.bboxSmall;
    voxelSize = param.raw.voxelSize;

    % load edges and borders
    load(cubeParams.borderFile, 'borders');
    load(cubeParams.edgeFile, 'edges');

    % load segmentation data
    seg = loadSegDataGlobal(param.seg, cubeBox);

    % run main function
    area = Seg.Local.physicalBorderArea2( ...
        borders, edges, seg, voxelSize);
end

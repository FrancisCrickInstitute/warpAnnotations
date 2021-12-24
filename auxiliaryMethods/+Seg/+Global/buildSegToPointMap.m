function buildSegToPointMap(param)
    % buildSegToPointMap(param)
    %   Builds and saves a global segment-to-point mapping
    %   in the dataset's root directory.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    rootDir = param.saveFolder;
    cubeCount = numel(param.local);
    
    % prepare cluster
    cluster = Cluster.getCluster( ...
        '-pe openmp 1', ...
        '-l h_vmem=12G', ...
        '-l s_rt=0:28:59', ...
        '-l h_rt=0:29:59');
    
    job = createJob(cluster);
    job.Name = 'segToPoint';
    
    % create tasks
    taskParams = arrayfun( ...
        @(idx) {{rootDir, idx}}, 1:cubeCount);
    createTask(job, @jobMain, 2, taskParams);
    
    % submit and wait
    submit(job);
    wait(job);
    
    % fetch data
    out = fetchOutputs(job);
    
    % build output
    segIds = vertcat(out{:, 1});
    points = vertcat(out{:, 2});
    
    % prepare map
    maxSegId = Seg.Global.getMaxSegId(param);
    segToPointMap = nan(maxSegId, 3);
    segToPointMap(segIds, :) = points;
    
    % save result
    outFile = [rootDir, 'segToPointMap.mat'];
    Util.save(outFile, segToPointMap);
end

function [segIds, points] = jobMain(rootDir, cubeIdx)
    % load parameters
    params = load([rootDir, 'allParameter.mat'], 'p');
    params = params.p;
    
    % launch function
    [segIds, points] = ...
        Seg.Local.getSegmentPoint(params, cubeIdx);
end
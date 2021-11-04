function [isoSurfs, emptyTrees] = buildIsoSurfaceOfSkel(param, nmlFile, varargin)
    % BUILDISOSURFACEOFSKEL
    %   Render iso-surfaces for each tree in a specified
    %   NML file.
    %
    % param
    %   Parameters produced by `run configuration.m`
    %
    % nmlFile
    %   Path to NML file. NOTE: The current NML parser
    %   only accepts ABSOLUTE paths!
    %
    % varargin
    %   All further input arguments are forwarded to the
    %   `buildIsoSurface` function. Please check out its do-
    %   cumentation for additional information.
    %
    % isoSurfs
    %   Nx1 cell array. Each cell contains the iso-
    %   surface for a tree in the NML file.
    % emptyTrees
    %   Nx1 logical array for trees that were empty
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    disp('Parsing NML file...');
    skel = skeleton(nmlFile);
    
    disp('Loading global segment ids...');
    segIds = Skeleton.getSegmentIdsOfSkel(param, skel);
    
    % clean up segment IDs
    segIds = cellfun( ...
        @(curSegIds) curSegIds(curSegIds > 0), ...
        segIds, 'UniformOutput', false);
    
    % ... and eliminate empty trees
    emptyTrees = cellfun(@isempty, segIds);
    segIds = segIds(~emptyTrees);
   
    % prepare cluster
    disp('Setting up cluster...');
    cluster = Cluster.config( ...
        'memory', 12, ...
        'time', '12:00:00');
    
    % create job
    job = createJob(cluster);
    job.Name = mfilename();
    
    % create task
    taskArgs = cellfun( ...
        @(curSegIds) {param, curSegIds, varargin{:}}, ...
        segIds, 'UniformOutput', false);
    createTask( ...
        job, @Visualization.buildIsoSurface, ...
        1, taskArgs, 'CaptureDiary', true);
    
    % run job
    disp('Starting job...');
    submit(job);
    wait(job);
    
    disp('Collecting results...');
    isoSurfs = fetchOutputs(job);
end


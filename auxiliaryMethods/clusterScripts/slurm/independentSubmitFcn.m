function independentSubmitFcn(cluster, job, props, varargin)
    % Copyright 2010-2012 The MathWorks, Inc.
    % 
    % Modified by
    %   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % Check type of cluster argument
    assert( ...
        isa(cluster, 'parallel.Cluster'), ...
        'Input argument must be Cluster object');

    assert( ...
        cluster.HasSharedFilesystem, ...
        'Only clusters with shared file sytems are supported');

    assert( ...
        strcmpi(cluster.OperatingSystem, 'unix'), ...
        'Only UNIX-like operating systems are supported');

    % Build submit script
    batchScriptPath = tempname();
    batchScript = Cluster.buildBatchScriptSlurm( ...
        cluster, job, props, varargin{:});
    
    % The batch script is now in a state where percent signs are supposed
    % to be taken literally. The only transformation we want `fprint` to do
    % is the conversion of \n, \r, and \t into the corresponding bytes. To
    % preserve percent signs, we have to escape them.
    batchScript = strrep(batchScript, '%', '%%');
    
    % Write batch script
    batchScriptFile = fopen(batchScriptPath, 'wt');
    fprintf(batchScriptFile, batchScript);
    fclose(batchScriptFile);

    % Now ask the cluster to run the submission command
    submitCommand = sprintf('sbatch "%s" < /dev/null', batchScriptPath);

    % Logging...
    dctSchedulerMessage( ...
        4, '%s: Submitting job with:\n\t%s\n', mfilename, submitCommand);

    try
        % Make the shelled out call to run the command.
       [cmdFailed, cmdOut] = system(submitCommand);
    catch err
        cmdFailed = true;
        cmdOut = err.message;
    end

    assert(~cmdFailed, 'Submit failed with message: %s', cmdOut);
    dctSchedulerMessage( ...
        1, '%s: Submission output: %s\n', mfilename, cmdOut);

    % set the job ID on the job cluster data
    clusterJobID = extractJobId(cmdOut);
    cluster.setJobClusterData( ...
        job, struct('ClusterJobIDs', {clusterJobID}));
end

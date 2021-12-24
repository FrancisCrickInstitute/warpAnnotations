function state = getJobStateFcn(cluster, job, state)
    % GETJOBSTATEFCN Gets the state of a job from Slurm
    %
    % Copyright 2010-2012 The MathWorks, Inc.
    % Modified by Alessandro Motta <alessandro.motta@brain.mpg.de>

    % Shortcut if the job state is already finished or failed
    if strcmp(state, 'finished') || strcmp(state, 'failed')
        return;
    end

    % Get the information about the actual cluster used
    data = cluster.getJobClusterData(job);

    jobIDs = data.ClusterJobIDs;
    jobIDsAsString = strjoin(arrayfun( ...
        @num2str, jobIDs, 'UniformOutput', false), ',');

    filename = tempname;
    commandToRun = sprintf('sacct -p --jobs="%s" > %s', jobIDsAsString, filename);
    dctSchedulerMessage(4, ...
        '%s: Querying cluster for job state using command:\n\t%s', ...
        mfilename, commandToRun);

    % Add some delay as otherwise this functions often errors on inital call(s) after job creation on Crick cluster
    % Note this will slow down polling, but it is slow anyway for large jobs, so lesser evil xD
    pause(10);
    try
        % We will ignore the status returned from the state command because
        % a non-zero status is returned if the job no longer exists
        % Make the shelled out call to run the command.
        system(commandToRun);
    catch err
        ex = MException( ...
            'parallelexamples:GenericSGE:FailedToGetJobState', ...
            'Failed to get job state from cluster.');
        ex.addCause(err);
        throw(ex);
    end

    clusterState = extractJobState(filename);
    dctSchedulerMessage(6, ...
        '%s: State %s was extracted from cluster output:\n', ...
        mfilename, clusterState);

    % If we could determine the cluster's state, we'll use that, otherwise
    % stick with MATLAB's job state.
    if ~strcmp(clusterState, 'unknown')
        state = clusterState;
    end
end

function state = extractJobState(filename)
    data = readtable(filename, 'ReadVariableNames', true);
    delete(filename);
    
    data = data(1:3:end,:); % remove unnecessary information
    if all(strcmp(data.State, 'COMPLETED'))
        state = 'finished';
    elseif any(strcmp(data.State, 'RUNNING'))
        state = 'running';
    elseif any(strcmp(data.State, 'PENDING'))
        state = 'queued';  
    else % there could be even more states...see https://slurm.schedmd.com/sacct.html#lbAG
        state = 'failed';
    end
end

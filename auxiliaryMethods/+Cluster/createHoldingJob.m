function job = createHoldingJob( ...
        cluster, afterJobs, varargin)
    % CREATEHOLDINGJOB
    %   Create a job that will wait for a set of other
    %   jobs to finish before being executed.
    %
    % cluster
    %   Cluster object created with Cluster.getCluster.
    % afterJobs
    %   A cell array of MATLAB jobs, which need to finish
    %   before 'job' will be executed.
    % varargin
    %   All remaining input arguments are key-value pairs
    %   that are passed to the 'createJob' function.
    %
    % job
    %   New MATLAB job that will hold its horses.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % config
    holdFlag = '-hold_jid';
    
    if ~iscell(afterJobs)
        afterJobs = {afterJobs};
    end
    
    % Step One
    %   Find SGE job ids for all jobs in 'afterJobs'
    jobIds = cellfun(@(j) ...
        {getClusterJobIds(cluster, j)}, afterJobs);
    jobIds = unique(vertcat(jobIds{:}));
    
    % Stop Two
    %   Build comma-separated list of job ids
    jobIdList = arrayfun(@(jid) {num2str(jid)}, jobIds);
    jobIdList = strjoin(jobIdList, ',');
    
    % Step Three
    %   Create a modified cluster object that has the
    %   right 'hold-for-job' flags
    oldSubmitArgs = cluster.IndependentSubmitFcn;
    
    % skip handle to submit function
    newSubmitArgs = oldSubmitArgs(2:end);
    
    % remove old flag
    hasHoldFlag = @(s) ...
        strncmp(s, holdFlag, numel(holdFlag));
    newSubmitArgs = newSubmitArgs(cellfun( ...
        @(s) ~hasHoldFlag(s), newSubmitArgs));
    
    % add new flag
    newFlag = [holdFlag, ' ', jobIdList];
    newSubmitArgs{end + 1} = newFlag;
    
    % create the holding cluster
    holdingCluster = ...
        Cluster.getCluster(newSubmitArgs{:});
    
    % Step Four
    %   Actually create job
    job = createJob(holdingCluster, varargin{:});
end       

function jobIds = getClusterJobIds(cluster, job)
    data = getJobClusterData(cluster, job);
    jobIds = data.ClusterJobIDs;
    
    % NOTE
    %   I cannot imagine a case in which there are multiple
    %   cluster job IDs for a single MATLAB job. Still,
    %   MATLAB uses a cell array to store the job ids...
    
    % convert cell array to numerical array
    jobIds = unique(vertcat(jobIds{:}));
    jobIdCount = numel(jobIds);
    
    if jobIdCount == 0;
        error('Found job without cluster job id');
    elseif jobIdCount > 1
        warning('Found job with multiple cluster job ids');
    end
end
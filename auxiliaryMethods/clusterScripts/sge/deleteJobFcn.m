function deleteJobFcn(cluster, job)
% DELETEJOBFCN Deletes a job on SGE
%
% Set your cluster's DeleteJobFcn to this function using the following
% command:
%     set(cluster, 'DeleteJobFcn', @deleteJobFcn);
%
% Copyright 2010-2012 The MathWorks, Inc.
% Modified by Alessandro Motta

% Store the current filename
currFilename = mfilename();

if ~isa(cluster, 'parallel.Cluster')
    error( ...
        'parallelexamples:GenericSGE:SubmitFcnError', ...
        ['The function %s is for use with clusters created using ', ...
        'the parcluster command.'], currFilename)
end

if ~cluster.HasSharedFilesystem
    error( ...
        'parallelexamples:GenericSGE:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', ...
        currFilename)
end

% Get the information about the actual cluster used
data = cluster.getJobClusterData(job);

if isempty(data)
    % This indicates that the job has not been submitted, so just return
    dctSchedulerMessage(1, ...
        '%s: Job cluster data was empty for job with ID %d.', ...
        currFilename, job.ID);
    return
end

try
    jobIDs = data.ClusterJobIDs;
catch err
    ex = MException( ...
        'parallelexamples:GenericSGE:FailedToRetrieveJobID', ...
        'Failed to retrieve clusters''s job IDs from the job cluster data.');
    ex = ex.addCause(err);
    throw(ex);
end

% Only ask the cluster to delete the job if it is hasn't reached a terminal
% state.  
erroredJobs = cell(size(jobIDs));
jobState = job.State;

if ~(strcmp(jobState, 'finished') || strcmp(jobState, 'failed'))
    % Get the cluster to delete the job
    for ii = 1:length(jobIDs)
        jobID = jobIDs{ii};
        commandToRun = sprintf('qdel "%d" < /dev/null', jobID);
        dctSchedulerMessage(4, ...
            '%s: Deleting job on cluster using command:\n\t%s.', ...
            currFilename, commandToRun);

        try
            % Make the shelled out call to run the command.
            [cmdFailed, cmdOut] = system(commandToRun);
        catch err
            cmdFailed = true;
            cmdOut = err.message;
        end
        
        if cmdFailed
            % Keep track of all jobs that errored when being deleted.
            % We'll report these later on.
            erroredJobs{ii} = jobID;
            dctSchedulerMessage(1, ...
                '%s: Failed to delete job %d on cluster. Reason:\n\t%s', ...
                currFilename, jobID, cmdOut);
        end
    end
end

% Now warn about those jobs that we failed to delete.
erroredJobs = erroredJobs(~cellfun(@isempty, erroredJobs));
if ~isempty(erroredJobs)
    warning( ...
        'parallelexamples:GenericSGE:FailedToDeleteJob', ...
        'Failed to delete the following jobs on the cluster:\n%s', ...
        sprintf('\t%s\n', erroredJobs{:}));
end

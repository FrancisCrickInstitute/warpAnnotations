function deleteJobFcn(cluster, job)
    % DELETEJOBFCN Deletes a job on Slurm
    %
    % Copyright 2010-2012 The MathWorks, Inc.
    % Modified by Alessandro Motta <alessandro.motta@brain.mpg.de>

    % nothing to do for finished or failed jobs
    if ismember(job.State, {'finished', 'failed'})
        return;
    end

    % Get the information about the actual cluster used
    data = cluster.getJobClusterData(job);
    jobIDs = data.ClusterJobIDs;

    commandToRun = sprintf('scancel %s', strjoin( ...
        arrayfun(@num2str, jobIDs, 'UniformOutput', false)));
    dctSchedulerMessage(4, ...
        '%s: Deleting job on cluster using command:\n\t%s.', ...
        mfilename, commandToRun);

    try
        cmdFailed = system(commandToRun);
    catch
        cmdFailed = true;
    end

    assert(~cmdFailed, ...
        'Failed to cancel job #%d (%s)', job.ID, job.Name);
end

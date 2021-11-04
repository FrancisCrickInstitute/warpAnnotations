function job = restartTasksWithErrors(job, cluster)
% Pass job object, will restart all tasks that had errors as new job pass
% 2nd argument is cluster object to be used
    
    idxError = Cluster.getIdxOfTasksWithError(job);
    inputCell = {job.Tasks(idxError).InputArguments};
    % Assumes all task in job execute the same function
    functionH = job.Tasks(1).Function;
    job = Cluster.startJob(functionH, inputCell, 'name', 'restartedTasks', 'cluster', cluster);

end


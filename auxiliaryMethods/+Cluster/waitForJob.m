function waitForJob(job, interval)
    % waitForJob(job, interval)
    %   Waits for one or multiple jobs and displays progress data in a
    %   regular interval (60 seconds by default).
    %
    % Written by
    %   Manuel Berning <manuel.berning@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    if nargin < 2 || isempty(interval)
        interval = 60;
    end
    
    for i = 1:numel(job)
        try
            jobId = job(i).Id;
            jobName = job(i).Name;
        catch
            % NOTE(amotta): See below for an explanation of why this
            % try-catch is required here.
            continue;
        end
        
        Util.log('Waiting for job %d: %s', jobId, jobName);
    end
    
    finished = false(size(job));
    while ~all(finished)
        pause(interval);
        
        for i = 1:numel(job)
            if finished(i); continue; end
            
            try
                jobId = job(i).Id;
                jobState = job(i).State;
                jobName = job(i).Name;
                errorCell = {job(i).Tasks(:).Error};
                stateCell = {job(i).Tasks(:).State};
            catch
                % NOTE(amotta): The above code might look innocent. But in
                % fact, MATLAB is accessing the job / task files to extract
                % these data. If the file is at the same time being written
                % by the worker, its content might be invalid, which causes
                % an error to be thrown.
                %
                % We don't care about this situation and simply will try
                % again during the next interval. A log statement is shown,
                % so that the user can detect the unlikely case that we get
                % stuck in an infinite loop.
                Util.log( ...
                   ['Encountered invalid job or task file. ', ...
                    'Will check again later..']);
                continue;
            end
            
            nrError = sum(~cellfun(@isempty, errorCell) | strcmp(stateCell, 'failed'));
            nrFinished = sum(strcmp(stateCell, 'finished') | strcmp(stateCell, 'failed'));
            nrPending = sum(strcmp(stateCell, 'pending'));
            nrRunning = sum(strcmp(stateCell, 'running'));
            
            Util.log( ...
               ['Job %d is %s. Tasks: %d finished, %d running, ', ...
                '%d pending, %d with errors'], jobId, jobState, ...
                nrFinished, nrRunning, nrPending, nrError);
            
            if nrError > 0
                taskId = find(~cellfun(@isempty, errorCell), 1);
               
                Util.log('%d tasks encountered errors', nrError);
                if any(~cellfun(@isempty, errorCell))
                    errorReport = getReport(errorCell{taskId});
                    Util.log('Task %d: %s', taskId, errorReport);
                else
                    Util.log('No Matlab error log found. Probably tasks ran into Out-Of-Memory');
                end
                error('Job %d threw an error', jobId);
            end
            
            if strcmp(jobState, 'finished')
                finished(i) = true;
                Util.log('Finished job %s', jobName);
            end
        end
    end
end

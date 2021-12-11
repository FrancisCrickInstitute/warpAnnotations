function taskId = hasLicenseError( job )
%HASLICENSEERROR Return all tasks with license errors by parsing the log
%files.
% INPUT job: parallel.job
% OUTPUT taskId: [Nx1] int
%           Ids of all tasks with license errors.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

cluster = job.Parent;
tasks = job.Tasks;
hasLicenseErrors = false(length(tasks), 1);
for i = 1:length(tasks)
    logFile = fullfile(cluster.JobStorageLocation, ...
        ['Job' num2str(job.Id)], ['Task' num2str(tasks(i).Id) '.log']);
    fId = fopen(logFile);
    try
        tline = fgetl(fId);
        while ischar(tline)
            if strcmp(tline, '======BEGIN LICENSE MANAGER ERROR======')
                hasLicenseErrors(i) = true;
                break
            end
            tline = fgetl(fId);
            
        end
        fclose(fId);
    catch err
        fclose(fId);
        rethrow(err);
    end
end
taskId = find(hasLicenseErrors);


end


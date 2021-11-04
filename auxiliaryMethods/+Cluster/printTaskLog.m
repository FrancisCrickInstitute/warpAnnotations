function [s, path] = printTaskLog( job, taskId )
%PRINTTASKLOG Return the task log file.
% INPUT job: parallel.job object
%       taskId: int
%           The task id.
% OUTPUT path: string
%           Full path to log file.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

cluster = job.Parent;
path = fullfile(cluster.JobStorageLocation, ['Job' num2str(job.Id)], ...
    ['Task' num2str(taskId) '.log']);
s = [];
fId = fopen(path);
try
    tline = fgetl(fId);
    while ischar(tline)
        s = [s, tline, '\n']; %#ok<AGROW>
        tline = fgetl(fId);
    end
    fclose(fId);
catch err
    fclose(fId);
    rethrow(err);
end
fprintf(s);

end


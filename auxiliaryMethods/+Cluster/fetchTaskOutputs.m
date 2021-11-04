function out = fetchTaskOutputs( job, taskIdx )
%FETCHTASKOUTPUTS Like fetchOutputs but only for specific tasks.
% INPUT job: parallel.job object
%           The job object for which to get the outputs.
%       taskIdx: (Optional) [Nx1] int or logical
%           Logical or linear indices of the tasks of a job for which the
%           outputs are fetched.
% OUTPUT out: [NxM] cell
%           Cell array where each row contains all outputs of corresponding
%           task in taskIdx or find(taskIdx) respectively.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('taskIdx', 'var') || isempty(taskIdx)
    tasks = job.Tasks;
else
    tasks = job.Tasks(taskIdx);
end
out = cell(length(tasks),1);

for i = 1:length(tasks)
    t = tasks(i);
    out{i} = t.OutputArguments;
end
out = vertcat(out{:});

end


function jobID = extractJobId(cmdOut)
% EXTRACTJOBID Extracts the job ID from the qsub command
% output. This is specific to array jobs on SGE.
% 
% Copyright 2010-2011 The MathWorks, Inc.
% Modified by Alessandro Motta <alessandro.motta@brain.mpg.de>

% The output of sbatch will be:
% Submitted batch job 247
jobNumberStr = regexp(cmdOut, 'batch job \d+', 'once', 'match');
jobID = sscanf(jobNumberStr, 'batch job %d');

% logging...
dctSchedulerMessage(0, ...
    '%s: Job ID %d was extracted from qsub output %s.', ...
    mfilename, jobID, cmdOut);
end

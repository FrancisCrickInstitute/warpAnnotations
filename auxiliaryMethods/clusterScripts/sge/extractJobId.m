function jobID = extractJobId(cmdOut)
% EXTRACTJOBID Extracts the job ID from the qsub command
% output. This is specific to array jobs on SGE.
% 
% Copyright 2010-2011 The MathWorks, Inc.
% Modified by Alessandro Motta

% The output of qsub will be:
% Your job-array XYZ ("yourJobName") has been submitted
jobNumberStr = regexp( ...
    cmdOut, 'job-array [0-9]*', 'once', 'match');
jobID = sscanf(jobNumberStr, 'job-array %d');

% logging...
dctSchedulerMessage(0, ...
    '%s: Job ID %d was extracted from qsub output %s.', ...
    mfilename, jobID, cmdOut);
end

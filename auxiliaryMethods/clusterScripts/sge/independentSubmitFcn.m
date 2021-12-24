function independentSubmitFcn(cluster, job, props, varargin)
% SUBMITFCN Submit a MATLAB job to the GABA cluster. All tasks
% belonging to said job are grouped together under a single
% job ID.
%
% All MATLAB files are stored in the location specified by
% the JobStorageLocation property of the cluster.
% 
% Usage example:
% cluster = parcluster();
% cluster.IndependentSubmitFcn = { ...
%     @Cluster.submitFcn, '-l h_vmem=8G'};
%
% Copyright 2010-2012 The MathWorks, Inc.
% Modified by
%   Benedikt Staffler
%   Alessandro Motta

quote = '''';
curFuncName = mfilename();

% Check type of cluster argument
if ~isa(cluster, 'parallel.Cluster')
    error( ...
        ['Error in %s: Cluster argument must be created ', ...
        'using the parcluster command.'], curFuncName);
end

% Only with shared file system
if ~cluster.HasSharedFilesystem
    error( ...
        'Error in %s: Function is for use with shared filesystems.', ...
        curFuncName);
end

% Only on Linux and UNIX
if ~strcmpi(cluster.OperatingSystem, 'unix')
    error( ...
        'Error in %s: Function is for use with UNIX-like OSes', ...
        curFuncName)
end

% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(props.MatlabArguments);

% Set decode function (no idea what this is used for...)
decodeFunction = 'parallel.cluster.generic.independentDecodeFcn';

% Setup job specific environment variables
% MDCE_TASK_LOCATION must always be last!
variables = { ...
    'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor; ...
    'MDCE_JOB_LOCATION', props.JobLocation; ...
    'MDCE_MATLAB_EXE', props.MatlabExecutable; ...
    'MDCE_MATLAB_ARGS', matlabArguments; ...
    'MDCE_DEBUG', 'true'; ...
    'MLM_WEB_LICENSE', props.UseMathworksHostedLicensing; ...
    'MLM_WEB_USER_CRED', props.UserToken; ...
    'MLM_WEB_ID', props.LicenseWebID; ...
    'MDCE_LICENSE_NUMBER', props.LicenseNumber; ...
    'MDCE_STORAGE_LOCATION', props.StorageLocation; };

% Remove empty variables
nonEmptyValues = cellfun( ...
    @(x) ~isempty(strtrim(x)), variables(:, 2));
variables = variables(nonEmptyValues, :);

% Additional submission arguments passed to qsub
if ~isempty(varargin)
    submitArgs = varargin;
elseif isprop(cluster.AdditionalProperties, 'submitArgCount')
    addProps = cluster.AdditionalProperties;
    
    submitArgCount = addProps.submitArgCount;
    submitArgs = cell(1, submitArgCount);
    
    for curIdx = 1:submitArgCount
        curName = sprintf('submitArg%d', curIdx);
        submitArgs{curIdx} = addProps.(curName);
    end
else
    submitArgs = {};
end

% Get the tasks for use in the loop
tasks = job.Tasks;
numberOfTasks = props.NumberOfTasks;
taskLocs = cell(numberOfTasks, 1);
taskLogs = cell(numberOfTasks, 1);

% Loop over every task we have been asked to submit
for taskIdx = 1:numberOfTasks ...
    % store path to task log
    taskLogs{taskIdx} = cluster.getLogLocation(tasks(taskIdx));
    taskLocs{taskIdx} = props.TaskLocations{taskIdx};
end

% Build submit script
jobScript = Cluster.buildJobScript( ...
    job.ID, job.Name, numberOfTasks, ...
    submitArgs, variables, taskLocs, taskLogs);

% Save
jobFilePath = tempname();
jobFile = fopen(jobFilePath, 'wt');
fprintf(jobFile, jobScript);
fclose(jobFile);

% Now ask the cluster to run the submission command
submitCommand = [ ...
    'qsub ', quote, jobFilePath, quote, ' < /dev/null'];

% Logging...
dctSchedulerMessage(4, ...
    '%s: Submitting job with:\n\t%s\n', ...
    curFuncName, submitCommand);

try
    % Make the shelled out call to run the command.
    [cmdFailed, cmdOut] = system(submitCommand);
catch err
    cmdFailed = true;
    cmdOut = err.message;
end

if cmdFailed
    error( ...
        'Error in %s: Submit failed with the following message.\n%s', ...
        curFuncName, cmdOut);
end

dctSchedulerMessage(1, ...
    '%s: Submission output: %s\n', ...
     curFuncName, cmdOut);

% set the job ID on the job cluster data
clusterJobID = {extractJobId(cmdOut)};
cluster.setJobClusterData(job, ...
    struct('ClusterJobIDs', {clusterJobID}));

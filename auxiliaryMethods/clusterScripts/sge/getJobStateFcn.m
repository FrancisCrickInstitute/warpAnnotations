function state = getJobStateFcn(cluster, job, state)
% GETJOBSTATEFCN Gets the state of a job from SGE
%
% Set your cluster's GetJobStateFcn to this function using the following
% command:
%     set(cluster, 'GetJobStateFcn', @getJobStateFcn);
%
% Copyright 2010-2012 The MathWorks, Inc.
% Modified by Alessandro Motta

currFilename = mfilename;

if ~isa(cluster, 'parallel.Cluster')
    error( ...
        ['Error in %s: This function is for use with clusters created ', ...
        'using the parcluster command.'], currFilename);
end

if ~cluster.HasSharedFilesystem
    error( ...
        ['Error in %s: ', ...
        'This submit function is for use with shared filesystems only.'], ...
         currFilename);
end

% Shortcut if the job state is already finished or failed
if strcmp(state, 'finished') || strcmp(state, 'failed');
    return;
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
  
% Get the full xml from qstat so that we can look for 
% <job_list state="pending">
% <job_list state="running">

filename = tempname;
commandToRun = sprintf('qstat -xml > %s', filename);
dctSchedulerMessage(4, ...
    '%s: Querying cluster for job state using command:\n\t%s', ...
    currFilename, commandToRun);

try
    % We will ignore the status returned from the state command because
    % a non-zero status is returned if the job no longer exists
    % Make the shelled out call to run the command.
    system(commandToRun);
catch err
    ex = MException( ...
        'parallelexamples:GenericSGE:FailedToGetJobState', ...
        'Failed to get job state from cluster.');
    ex.addCause(err);
    throw(ex);
end

clusterState = iExtractJobState(filename, jobIDs);
dctSchedulerMessage(6, ...
    '%s: State %s was extracted from cluster output:\n', ...
    currFilename, clusterState);

% If we could determine the cluster's state, we'll use that, otherwise
% stick with MATLAB's job state.
if ~strcmp(clusterState, 'unknown')
    state = clusterState;
end

function state = iExtractJobState(filename, requestedJobIDs)
% Function to extract the job state for the requested jobs from the 
% output of qstat -xml

% use xmlread to read in the file
try
    xmlFileDOM = xmlread(filename);
catch err
    currFilename = mfilename;
    dctSchedulerMessage(4, ...
    '%s: Error while parsing the output of ''qstat -xml'':\n\n%s\n\n', ...
    currFilename, err.getReport());

    % Try to log the contents of the file that contains the job state
    try
        fid = fopen(filename, 'r'); 
        cleanupObj = onCleanup(@() fclose(fid));
        fileContents = fread(fid, inf, '*char');
        dctSchedulerMessage(4, ...
        '%s: Contents of file ''%s'': \n\n%s\n\n', ...
        currFilename, filename, fileContents);
    catch err2 %#ok<NASGU>
        % It is OK if we can't log the contents of the file.
    end
    warning( ...
        'parallelexamples:GenericSGE:FailedToReadQstatXmlFile', ...
        ['Unable to retrieve job state. Try again in 60 seconds. ', ...
        'If the issue persists contact MathWorks Technical Support.']);
    state = 'unknown';
    return
end

% now delete the temporary file
delete(filename);

% We expect the XML to be in the following format:
%  <queue_info>
%    <job_list state="running">
%      <JB_job_number>535</JB_job_number>
%      <JAT_prio>0.55500</JAT_prio>
%      <JB_name>Job1.1</JB_name>
%      <JB_owner>elwinc</JB_owner>
%      <state>r</state>
%      <JAT_start_time>2010-01-28T05:56:27</JAT_start_time>
%      <queue_name>all.q@dct13glnxa64.mathworks.com</queue_name>
%      <slots>1</slots>
%    </job_list>
%
% Find the correct JB_job_number node and get the parent to find out 
% the job's state
% the job's state
allJobNodes = xmlFileDOM.getElementsByTagName('JB_job_number');

numJobsFound = allJobNodes.getLength();
if numJobsFound == 0
    % No jobs in the qstat output, so the one we are interested in
    % must be finished
    state = 'finished';
    return;
end

stateParseError = MException( ...
    'parallelexamples:GenericSGE:StateParseError', ...
    ['Failed to parse XML output from qstat.', ...
    'Could not find "state" attribute for job_list node.']);

for ii = 0:allJobNodes.getLength() - 1
    jobNode = allJobNodes.item(ii);
    jobNumber = str2double(jobNode.getFirstChild.getData);
    
    isEqualFcn = @(x) isequal(jobNumber, x);
    if any(cellfun(isEqualFcn, requestedJobIDs))
        % Only get the parent node if the current node is a
        % job that we are interested in.
        jobParentNode = jobNode.getParentNode;
        % We were expecting the state attribute
        if ~jobParentNode.hasAttributes
            throw(stateParseError);
        end
        
        stateAttribute = jobParentNode.getAttributes.getNamedItem('state');
        if isempty(stateAttribute)
            throw(stateParseError);
        end
        
        % We've got the state for the job that we are interested in.
        jobState = char(stateAttribute.getValue);
        if strcmpi(jobState, 'running');
            % If any of the requested jobs are running, then the whole
            % job is still running, so we can stop searching and just
            %return with state running
            state = 'running';
            return;
        end
    end
end

state = 'unknown';

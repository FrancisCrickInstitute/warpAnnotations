function job = startJob( fh, inputCell, varargin )
    % job = startJob( fh, inputCell, varargin )
    %   Execute a function on a cluster or locally.
    %
    %  INPUT fh:
    %          Function handle which is executed on the worker.
    %
    %        inputCell:
    %          [Nx1] cell array where each cell contains the input to
    %          one task.
    %
    %        varargin:
    %          Name-value pairs specifying modifying the default behaviour.
    %
    %          numOutputs:
    %            Integer specifying how many outputs are collected.
    %            (Default: 0)
    %
    %          sharedInputs:
    %            [Nx1] cell array of inputs shared between all workers and
    %            reducing io. When using sharedInputs a file is created in
    %            the job storage location folder which will be automatical-
    %            ly deleted when deleting the job from matlab. Shared
    %            inputs are passed as first arguments to the function
    %            handle by default (see also sharedInputsLocation).
    %            (Default: [])
    %
    %          sharedInputsLocation:
    %            [Nx1] int array specifying the location of the respective
    %            shared input within all inputs of the function handle.
    %            (Default: 1:N)
    %
    %          cluster:
    %            Cell array of strings with options for Cluster.config or
    %            parallel.cluster object which is used for job submission.
    %            (Default: Default value of Cluster.config)
    %
    %          taskGroupSize:
    %            Integer indicating if several tasks should be grouped
    %            together and run as a single task.
    %            (Default: 1)
    %
    %          attachFolder:
    %            String or cell array of strings containing folder that are
    %            attached to the job. (see Cluster.attachFolder)
    %            (Default: pwd and path)
    %
    %          excludeSubfolder:
    %            see Cluster.attachFolder
    %            (Default: true)
    %
    %          autoAttachFiles:
    %            see Cluster.attachFolder
    %            (Default: false)
    %            Note that autoAttachFiles is currently not working because
    %            the function handle we are using to submit the job is not
    %            the input function handle.
    %
    %          name:
    %            String to set job name.
    %
    %          diary:
    %            Optional logical flag to capture the job diary.
    %            (Default: true)
    %
    %  OUTPUT job: A matlab parallel.job object.
    %
    %  NOTE If taskGroupSize > 1 and fhArgsOut > 0 then the result of
    %       fetchOutputs(job) will be a cell array of length number of
    %       tasks of the job with each cell containing the output for the
    %       corresponding group of tasks in the standard format. To recover
    %       the default output in this case use
    %
    %       out = fetchOutputs(job);
    %       out = vertcat(out{:});
    %
    % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

    % default arguments
    args.fh = fh;
    args.numOutputs = 0;
    args.sharedInputs = [];
    args.sharedInputsLocation = [];
    args.cluster = [];
    args.taskGroupSize = 1;
    args.attachFolder = path;
    args.excludeSubfolder = true;
    args.autoAttachFiles = false;
    args.name = [];
    args.diary = true;

    % overwrite with user specified options
    if ~isempty(varargin)
        opts = varargin(1:2:end);
        optExists = ismember(opts, fieldnames(args));
        if ~all(optExists)
            error('Unrecognized options ''%s''.\n', ...
                opts{find(~optExists,1)});
        end
        args = Util.modifyStruct(args, varargin{:});
    end
    
    % set default value for location of shared inputs
    if ~isempty(args.sharedInputs) && isempty(args.sharedInputsLocation)
        args.sharedInputsLocation = 1:numel(args.sharedInputs);
    end

    % check sharedInputsLocations
    assert( ...
       numel(args.sharedInputs) == numel(args.sharedInputsLocation), ...
       'Found %d shared inputs, but only %d shared input locations', ...
       numel(args.sharedInputs), numel(args.sharedInputsLocation));

    % get cluster object
    % throw error if unrecognized input argument has unsupported class
    if isa(args.cluster, 'parallel.Cluster')
        cluster = args.cluster;
    elseif ischar(args.cluster)
        warning( ...
            'Cluster:startJob:clusterOptionIsChar', ...
           ['Using strings for cluster configuration is deprecated ', ...
            'and will be removed in the future.']);
        cluster = Cluster.getCluster(args.cluster);
    elseif iscell(args.cluster)
        if any(strncmp('-', args.cluster, 1))
            warning( ...
                'Cluster:startJob:clusterOptionIsSgeSpecificCellArray', ...
               ['Passing `qsub`-specific options to `startJob` is ', ...
                'deprecated and will stop working in the future.']);
            cluster = Cluster.getCluster(args.cluster{:});
        else
            cluster = Cluster.config(args.cluster{:});
        end
    elseif isempty(args.cluster)
        cluster = Cluster.config();
    else
        error('Unrecognized input in cluster input argument.');
    end
    
    % empty input cluster before saving args
    args.cluster = [];

    % create job for cluster
    job = createJob(cluster);

    % get temporary path in job folder
    sharedFileDir = fullfile( ...
        cluster.JobStorageLocation, ['Job', num2str(job.Id)]);
    sharedFile = fullfile(sharedFileDir, 'SharedInputs.mat');

    % group task inputs
    inputCell = arrayfun(@(idx) inputCell( ...
        idx:min(idx + args.taskGroupSize - 1, numel(inputCell))), ...
        1:args.taskGroupSize:numel(inputCell), 'UniformOutput', false);

    % add shared input file
    inputCell = cellfun( ...
        @(inputs) {sharedFile, inputs}, ...
        inputCell, 'UniformOutput', false);

    % set job name
    if ~isempty(args.name)
        % Replace spaces with underscores
        % SGE and the job submission script can't handle it
        args.name = strrep(args.name, ' ', '_');
        job.Name = sprintf('%s_Job%d', args.name, job.Id);
    end

    % attach folders
    job = Cluster.attachFolder(job, args.attachFolder, ...
        args.autoAttachFiles, args.excludeSubfolder);

    % determine number of outputs
    if args.taskGroupSize > 1 && args.numOutputs ~= 0
        numOutputs = 1;
    else
        numOutputs = args.numOutputs;
    end

    % create tasks
    createTask( ...
        job, @jobWrapper, numOutputs, ...
        inputCell, 'CaptureDiary', args.diary);

    % save temporary data to job folder
    % this only works after calling createTask
    Util.saveStruct(sharedFile, args);

    submit(job);
end

function varargout = jobWrapper(sharedFile, taskInputs)
    % Job wrapper, which will be executed on worker. The first input
    % contains the path to a file with optional, inputs that are shared
    % among multiple tasks.

    % load shared inputs
    args = load(sharedFile);

    % prepare output
    taskCount = numel(taskInputs);
    out = cell(taskCount, args.numOutputs);

    % run tasks
    for curIdx = 1:taskCount
        % collect all inputs
        curInputs = taskInputs{curIdx};
        curInputs = [args.sharedInputs(:); curInputs(:)];

        % fix order
        curInputIds = args.sharedInputsLocation(:);
        curInputIds((end + 1):numel(curInputs)) = ...
            setdiff(1:numel(curInputs), curInputIds(:));
        curInputs(curInputIds) = curInputs;

        [out{curIdx, :}] = args.fh(curInputs{:});
    end

    % re-pack output, if needed
    if args.taskGroupSize > 1 && args.numOutputs ~= 0
        out = {out};
    end

    varargout = out;
end

function cluster = config(varargin)
    % cluster = Cluster.config(varargin)
    %   Configure a MATLAB `parallel.Cluster` object for job submission to
    %   the GABA compute cluster. If this function is called from a machine
    %   that is not connected to GABA, it will return a local cluster (see
    %   `parallel.cluster.Local`).
    %
    % Inputs
    %   All of the following key-value pairs are optional.
    %
    %   memory (default: 6)
    %     Integer number of gigabytes of RAM per task. If the requested
    %     amount of memory is zero, Slurm will allocate whole nodes.
    %
    %   time (default: '1:00:00');
    %     Maximum wall-clock time per task in hours:minutes:seconds format.
    %     Tasks which exceed this limit will be killed by the scheduler.
    %     They may or may not be marked as 'Failed' by MATLAB.
    %
    %   priority (default: 50)
    %     Job priority in the range from 0 to 100. Higher values correspond
    %     to higher priorities. This value is automatically translated to
    %     the scheduler-specific ranges.
    %
    %   taskConcurrency (default: 50)
    %     Maximum number of tasks to be executed concurrently. If this
    %     value is zero, the task concurrency is unlimited. On a local
    %     cluster, this value is used to configure the number of workers.
    %
    %   cores (default: 1)
    %     Integer number of cores per task.
    %
    %     Number of cores to reserve for each task. If multiple cores are
    %     requested, MATLAB versions R2017a and newer will execute tasks
    %     using multi-threading.
    %
    %   gpus (default: 0)
    %     Integer number of GPUs per task.
    %
    %   scheduler (default: 'slurm' if on GABA, 'local' otherwise)
    %     Name of scheduler to use for job submissions. We currently
    %     support Slurm ('slurm'), the Sun Grid Engine ('sge'), and local
    %     MATLAB clusters ('local'). For more information on the latter,
    %     see also parallel.cluster.Local.
    %
    %   partition (default: 'p.gaba' for Slurm, 'openmp' for SGE)
    %     Name of cluster partition to use for job submission. On the Sun
    %     Grid Engine, this value corresponds to the parallel environment.
    %     
    %   jobStorageLocation (default: '/tmpscratch/$USER/data/matlab-jobs' on GABA)
    %     Path to directory in which MATLAB will store all job- and
    %     task-related files. The directory will be created if it does not
    %     yet exist.
    %
    % Example
    %   cluster = Cluster.config( ...
    %       'scheduler', 'slurm', ...
    %       'priority', 50, ...
    %       'memory', 6, ...
    %       'time', '1:00:00', ...
    %       'taskConcurrency', 10, ...
    %       'gpus', 1);
    %
    %   OR
    %   
    %   cluster = Cluster.config( ...
    %       'priority', 100, ...
    %       'memory', 6, ...
    %       'time', '1:00:00', ...
    %       'scheduler', 'sge');
    %
    %   job = createJob(cluster);
    %   job.Name = 'buildRandMat';
    %
    %   createTask(job, @rand, 1, {10, 10});
    %   submit(job);
    %
    % Written by
    %   Sahil Loomba <sahil.loomba@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % config
    gabaRegex = '^.*\.camp\.thecrick\.org$';
    args = parseArgs(varargin{:});
    
    % check if we're on GABA
    cluster = parallel.cluster.Generic();
    isGaba = ~isempty(regexp(cluster.Host, gabaRegex, 'once'));
    useLocal = ~isGaba || strcmpi(args.scheduler, 'local');

    if useLocal
        % Parallelize over cores of local machine, if we're not on GABA or
        % if the user explicitly asked for this behaviour.
        cluster = parallel.cluster.Local();
    end

    % make sure job storage location exists
    if ~exist(args.jobStorageLocation, 'dir')
        mkdir(args.jobStorageLocation);
    end

    cluster.JobStorageLocation = args.jobStorageLocation;
    cluster.HasSharedFilesystem = true;
    
    if args.cores > 1
        if verLessThan('matlab', '9.2') % R2017a
            warning( ...
                'Cluster:config', ...
               ['Cluster.config does not support multi-threaded ', ...
                'workers in MATLAB versions prior to R2017a. The ', ...
                'tasks will be run on single threads.']);
        else
            cluster.NumThreads = args.cores;
        end
    end

    if useLocal
        cluster = configLocal(cluster, args);
    else
        cluster = configGaba(cluster, args);
    end
end

function cluster = configLocal(cluster, args)
    if args.taskConcurrency > 0
        cluster.NumWorkers = args.taskConcurrency;
    end
end

function submitArgs = buildSubmitFcnArguments(args)
    switch args.scheduler
        case 'sge'
            submitArgs = buildSgeSubmitFcnArguments(args);
        case 'slurm'
            submitArgs = buildSlurmSubmitFcnArguments(args);
    end
end

function submitArgs = buildSgeSubmitFcnArguments(args)
    % Our user-facing priorities go from 0 (lowest priority) to 100
    % (highest priority). Let's translate this to SGE's -1000 to 0.
    priority = 10 * args.priority - 1000;
    
    submitArgs = { ...
        sprintf('-pe %s %d', args.partition, args.cores), ...
        sprintf('-l h_vmem=%dG', args.memory), ...
        sprintf('-l h_rt=%s', args.time), ...
        sprintf('-p %d', priority)};
    
    if args.taskConcurrency > 0
        submitArgs{end + 1} = sprintf( ...
            '-tc %d', args.taskConcurrency);
    end
end

function submitArgs = buildSlurmSubmitFcnArguments(args)
    % HACK(amotta); Unfortunately, the task concurrency is passed to Slurm
    % via the same option (`--array`) which also contains the total number
    % of tasks. But at the time of cluster configuration, we do not yet
    % know the task count.
    %
    % As a workaround, we forward to the Slurm integration script not the
    % final --array option for `sbatch`, but a format string that can be
    % used to fill in the task count.
    %
    % The submit function is supposed to replace the `{:taskCount:}`
    % placeholder by the actual value!
    memoryPerCore = ceil(args.memory / args.cores);
    niceness = round(10000 * (1 - args.priority / 100));
    taskConcurrency = '--array=1-{:taskCount:}';
    
    if args.taskConcurrency > 0
        taskConcurrency = sprintf('%s%%%d', ...
            taskConcurrency, args.taskConcurrency);
    end
    
    submitArgs = { ...
        sprintf('--partition=%s', args.partition), ...
        sprintf('--cpus-per-task=%d', args.cores), ...
        sprintf('--mem=%dG', memoryPerCore), ...
        sprintf('--time=%s', args.time), ...
        sprintf('--nice=%d', niceness), ...
        taskConcurrency};

    if args.gpus > 0
        % TODO: Allow user to specify type of GPU
        submitArgs{end + 1} = sprintf('--gres=gpu:%d', args.gpus);
    end
end

function cluster = configGaba(cluster, args)
    submitFcnArguments = buildSubmitFcnArguments(args);
    
    cluster = ...
        Cluster.Internal.configMatlabClusterObject( ...
            cluster, args.scheduler, submitFcnArguments);
end

function args = parseArgs(varargin)
    parser = inputParser();
    parser.FunctionName = mfilename();
    
    addParameter(parser, 'jobStorageLocation', ...
        fullfile('/camp', 'project', 'proj-emschaefer', 'scratch', 'matlab-jobs', getenv('USER')), ...
        @(x) validateattributes(x, {'char'}, {'nonempty'}));
    
    addParameter(parser, 'scheduler', 'slurm', ...
        @(x) any(validatestring(x, {'sge', 'slurm', 'local'})));
    
    addParameter(parser, 'partition', '', ...
        @(x) validateattributes(x, {'char'}, {'nonempty'}));
    
    % TODO: Think about switching to `nonnegative`
    addParameter(parser, 'cores', 1, @(x) validateattributes( ...
        x, {'numeric'}, {'scalar', 'integer', 'positive'}));
    
    % NOTE(amotta): If the user requests zero memory, this is interpreted
    % as "just give me all the damn RAM available on the node". That's also
    % Slurms' interpreation of the memory value.
    addParameter(parser, 'memory', 6, @(x) validateattributes( ...
        x, {'numeric'}, {'scalar', 'integer', 'nonnegative'}));
    
    % TODO: Improve validation of time format
    addParameter(parser, 'time', '1:00:00', ...
        @(x) validateattributes(x, {'char'}, {'nonempty'}));
    
    addParameter(parser, 'priority', 50, @(x) validateattributes( ...
        x, {'numeric'}, {'scalar', 'integer', '>=', 0, '<=', 100}));
    
    addParameter(parser, 'taskConcurrency', 1000, @(x) validateattributes( ...
        x, {'numeric'}, {'scalar', 'integer', 'nonnegative'}));
    
    addParameter(parser, 'gpus', 0, @(x) validateattributes( ...
        x, {'numeric'}, {'scalar', 'integer', 'nonnegative'}));
    
    parse(parser, varargin{:});
    args = parser.Results;
    
    % Set scheduler-specific default values
    switch args.scheduler
        case 'sge'
            defaultPartition = 'openmp';
        case 'slurm'
            defaultPartition = 'cpu';
        otherwise
            defaultPartition = '';
    end
    
    if isempty(args.partition)
        args.partition = defaultPartition;
    end
end


function cluster = getCluster(varargin)
    % GETCLUSTER
    %   Create a cluster object with given configuration.
    %
    % Default values
    %   Queue: OpenMP
    %   Job priority: -500
    %   Memory limit: 6 GB
    %   Run-time limit: 1 hour
    %
    % Example
    %   cluster = Cluster.getCluster( ...
    %       '-pe openmp 1', ...
    %       '-p -600', ...
    %       '-l h_vmem=12G', ...
    %       '-l s_rt=02:59:00', ...
    %       '-l h_rt=03:00:00');
    %
    %   job = createJob(cluster);
    %   job.Name = 'buildRandMat';
    %
    %   createTask(job, @rand, 1, {10, 10});
    %
    % Written by
    %   Benedikt Staffler
    %
    % Modified by
    %   Alessandro Motta
    
    warning( ...
        'Cluster:getCluster', ...
       ['Cluster.getCluster only supports job submission to the Sun ', ...
        'Grid Engine. This function has been superseded by Cluster.', ...
        'config, and is no longer maintained.']);
    
    % config
    clusterRegex = '^gaba\d*\.opt\.rzg\.mpg\.de$';

    % load default cluster
    cluster = parallel.cluster.Generic;
    
    % check if we're on GABA
    clusterHost = cluster.Host;
    clusterFlag = ~isempty(regexp( ...
        clusterHost, clusterRegex, 'once'));

    % if not on gaba use a different cluster type
    if ~clusterFlag
        cluster = parallel.cluster.Local();
        % use 4 workers on a local cluster by default for now
        if isnumeric(varargin{1})
            numWorkers = varargin{1};
        else
            numWorkers = 4;
        end
    end
    
    % set location for job-related data
    jobStorageLocation = [ ...
        Util.getTempDir(), 'data/matlab-jobs/'];

    % make sure job storage location exists
    if ~exist(jobStorageLocation, 'dir')
        mkdir(jobStorageLocation);
    end

    % then set accordingly in cluster object
    cluster.JobStorageLocation = jobStorageLocation;
    cluster.HasSharedFilesystem = true;

    % Specific settings dependent on type of cluster
    if clusterFlag
        cluster = configGABA(cluster, varargin);
    else
        cluster = configLocal(cluster,numWorkers);
    end
end

function cluster = configLocal(cluster,numWorkers)
    cluster.NumWorkers = numWorkers;
end

function cluster = configGABA(cluster, submitFcnArguments)
    cluster = ...
        Cluster.Internal.configMatlabClusterObject( ...
            cluster, 'sge', fillDefaultArgs(submitFcnArguments));
end

function args = fillDefaultArgs(args)
    % anonymous function to check for flags
    % and resource limits
    hasFlag = @(str, flag) ...
        ~isempty(strfind(str, [flag, ' ']));
    hasLimit = @(str, flag) ...
        ~isempty(strfind(str, [flag, '=']));

    % check if priority and parallel environment
    % were manually set by user
    hasPriority = any(cellfun( ...
        @(arg) hasFlag(arg, '-p'), args));
    hasParallelEnv = any(cellfun( ...
        @(arg) hasFlag(arg, '-pe'), args));
    hasNotify = any(strcmpi(args, '-notify'));
    
    hasVmemLimit = any(cellfun( ...
        @(arg) hasLimit(arg, 'h_vmem'), args));
    hasRtLimit = any(cellfun( ...
        @(arg) hasLimit(arg, 'h_rt'), args));
    
    % use defaults for missing values
    if ~hasPriority; args{end + 1} = '-p -500'; end;
    if ~hasParallelEnv; args{end + 1} = '-pe openmp 1'; end;
    if ~hasVmemLimit; args{end + 1} = '-l h_vmem=6G'; end;
    if ~hasNotify; args{end + 1} = '-notify'; end;
    
    if ~hasRtLimit
        args{end + 1} = '-l h_rt=1:00:00';
        args{end + 1} = '-l s_rt=0:59:00';
    end
end


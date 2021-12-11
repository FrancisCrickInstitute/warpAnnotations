function cluster = ...
        configMatlabClusterObject(cluster, scheduler, submitArgs)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % Cluster scripts are located in `../../clusterScripts`
    scriptDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    scriptDir = fullfile(scriptDir, 'clusterScripts');
    schedulerDir = fullfile(scriptDir, scheduler);
    
    if verLessThan('matlab', '9.3.0')
        % We've implemented `independentSubmitFcn`, `getJobStateFcn`, and
        % `DeleteJobFcn` for both SGE and Slurm. To choose a scheduler we
        % have to make sure that the desired one has priority on the search
        % path. The easiest way to achieve this is by making sure that only
        % the user-specified scheduler is the only one on the path.
        previousWarning = warning('off', 'MATLAB:rmpath:DirNotFound');
        rmpath(genpath(scriptDir));
        warning(previousWarning);
        addpath(schedulerDir);
        
        cluster.GetJobStateFcn = @getJobStateFcn;
        cluster.DeleteJobFcn = @deleteJobFcn;
        cluster.IndependentSubmitFcn = [ ...
            {@independentSubmitFcn}; submitArgs(:)];
    else
        % Newer MATLAB versions are slightly less annoying to use, in the
        % sense that they let us directly specify the scheduler scripts.
        cluster.IntegrationScriptsLocation = schedulerDir;
        
        % Forward arguments to cluster additional properties
        submitArgCount = numel(submitArgs);
        for curIdx = 1:submitArgCount
            curKey = sprintf('submitArg%d', curIdx);
            cluster.AdditionalProperties.(curKey) = submitArgs{curIdx};
        end

        % Also store number of arguments for read-out
        cluster.AdditionalProperties.submitArgCount = submitArgCount;
    end
end

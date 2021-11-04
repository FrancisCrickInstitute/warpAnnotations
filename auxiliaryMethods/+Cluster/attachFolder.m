function job = attachFolder(job, dirs, autoAttachFiles, excludeSubDirs)
    % job = attachFolder(job, dirs, autoAttachFiles, excludeSubDirs)
    %   Set search path of the job to the specified directories.
    %   Optionally, these directories might be attached to the job by
    %   copying their contents.
    %
    %   folder
    %     String or cell array of strings specifying the directory to add.
    %     Subdirectories are included by default (see excludeSubDirs).
    %     Use pwd for current folder.
    %
    %   autoAttachFile (optional)
    %     Logical to set the autoAttachFiles property of a job.
    %     Default: false
    %
    %   excludeSubDirs (optional)
    %     Logical to exclude subfolders of specified folders.
    %     Default: true
    %
    % Authors
    %   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    if ~exist('excludeSubDirs', 'var') || isempty(excludeSubDirs)
        excludeSubDirs = true;
    end

    if ~exist('autoAttachFiles', 'var') || isempty(autoAttachFiles)
        autoAttachFiles = false;
    end

    if ischar(dirs)
        dirs = strsplit(dirs, pathsep());
        dirs = dirs(~cellfun(@isempty, dirs));
    end

    % build list of folders
    buildPathsFunc = @(p) buildPaths(p, excludeSubDirs);
    dirs = cellfun(buildPathsFunc, dirs, 'UniformOutput', false);
    dirs = unique(vertcat(dirs{:}));
    
    % remove MATLAB paths
    isInMatlabPath = @(x) strncmpi(x, matlabroot, numel(matlabroot));
    dirs = dirs(~cellfun(isInMatlabPath, dirs));
    
    % remove duplicate paths
    dirs = unique(dirs, 'stable');
    
    % update job
    job.AutoAttachFiles = autoAttachFiles;
    job.AdditionalPaths = [job.AdditionalPaths(:); dirs(:)];
end

function paths = buildPaths(rootDir, excludeSubDirs)
    if excludeSubDirs
        paths = {rootDir};
    else
        paths = genpath(rootDir);
        paths = strsplit(paths, pathsep());
    end
    
    % remove empty paths, which might be generated
    % because the output of genpath ends with a pathsep
    paths = paths(~cellfun(@isempty, paths));
    
    % remove "hidden" directories, whose
    % names start with a dot (such as .git)
    keep = @(p) isempty(strfind(p, [filesep(), '.']));
    paths = paths(cellfun(keep, paths));
    
    % make column vector
    paths = paths(:);
end
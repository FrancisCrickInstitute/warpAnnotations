function protect(files, recursive)
    % protect(files)
    %   Protect files and / or directories by removing write permissions.
    %
    % files
    %   String or cell array of strings.
    %   Path of file or directory to protect.
    %
    % recursive
    %   Boolean (default: false).
    %   If true, change permissions recursively.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    if ~iscell(files)
        files = {files};
    end
    
    if ~exist('recursive', 'var') ...
            || isempty(recursive)
        recursive = false;
    end
    
    recursiveOpt = {'', '--recursive'};
    recursiveOpt = recursiveOpt{1 + logical(recursive)};
    
    errorCode = cellfun(@(f) system(sprintf( ...
        'chmod %s a-w "%s"', recursiveOpt, f)), files);
    assert(~any(errorCode));
end
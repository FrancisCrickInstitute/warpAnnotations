function [ gitRepos ] = getGitReposOnPath()
%GETGITREPOSONPATH Determine all git repositories on the current path.
% OUTPUT gitRepos: [Nx1] cell
%           Cell array with path to all folders on the path containing a
%           .git folder.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

pt = path();
pt = strsplit(pt, pathsep);

% The working directory is implicitly part of the search path.
pt{end + 1} = pwd();

% remove paths within MATLAB root
isPrefix = @(p) @(x) strncmpi(x, p, numel(p));
isInMatlabPath = isPrefix(matlabroot);
pt = pt(~cellfun(isInMatlabPath, pt));

%% search `.git` directory
% For each directory on path, we need to check if it or any of its parent
% directories contains a `.git` repository. We use the facts that
% * `fileparts(path)` gives the parent of `path`
% * `fileparts(path)` is `path` at the root of the file system

allDirs = cell(0, 1);
hasGitDir = false(0, 1);

for curIdx = 1:numel(pt)
    prevDir = [];
    curDir = pt{curIdx};
    
    while ~(isequal(curDir, prevDir) ...
            || ismember(curDir, allDirs))
        allDirs{end + 1} = curDir; %#ok
        hasGitDir(end + 1) = exist( ...
            fullfile(curDir, '.git'), 'dir'); %#ok
        
        prevDir = curDir;
        curDir = fileparts(curDir);
    end
end

gitRepos = allDirs(hasGitDir);
gitRepos = gitRepos(:);
end


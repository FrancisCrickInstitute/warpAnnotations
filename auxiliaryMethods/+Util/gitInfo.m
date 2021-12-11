function git_info = gitInfo(folder)
%GITINFO Some git information about the repository of the current folder.
% INPUT folder: (Optional) string
%           Folder for which the git status is queried.
%           (Default: pwd)
% OUTPUT info: struct
%           Struct containing the field.
%           hash (git rev-parse HEAD)
%           status (git status --porcelain)
%           remote (git config --get remote.origin.url)
%           diff (git diff)
%           local (pwd) - local folder where the git commands were run
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if exist('folder', 'var') && ~isempty(folder)
    curFolder = pwd;
    cd(folder);
end

try
    git_info.hash = Util.getGitHash();
catch
    warning('Could not retrieve git hash.');
    git_info.hash = [];
end

[status, git_status] = system('git status --porcelain');
if status
    warning('Could not retrieve git status.');
    git_info.status = [];
else
    git_info.status = strtrim(git_status);
end


[status, remote] = system('git config --get remote.origin.url');

if status
    warning('Could not retrieve git remote.');
    git_info.remote = [];
else
    git_info.remote = strtrim(remote);
end

[~, git_diff] = system('git diff --no-color --exit-code');
git_info.diff = strtrim(git_diff);
git_info.local = pwd;

if exist('curFolder', 'var')
    cd(curFolder);
end

end

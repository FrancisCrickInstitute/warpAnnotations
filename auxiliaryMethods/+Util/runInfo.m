function [ info ] = runInfo(saveParams)
%RUNINFO Save some information about a function/script run.
% INPUT saveParams: (Optional) logical
%           Flag indicating to save all parameters of parent workspace at
%           the timepoint this function is called.
%           (Default: true)
%       folder: (Optional) string
%           Changes the folder before collecting run data. This can be used
%           to get the git information of different git respositories on
%           the path.
% OUTPUT info: struct
%           Info struct about function run containing the following fields.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

git_repos = Util.getGitReposOnPath();

if isempty(git_repos)
    warning('No git repos found on path');
end

% git
git_info = cell(length(git_repos), 1);
for i = 1:length(git_info)
    git_info{i} = Util.gitInfo(git_repos{i});
end

% the function that ran
ST = dbstack('-completenames');
if length(ST) > 1 % called from function or script
    caller = ST(2); %second should the the caller of log
    idx = strfind(caller.file, '+');
    if isempty(idx)
        [~, cname] = fileparts(caller.file);
    else
        [~, cname] = strtok(caller.file, '+');
        cname = cname(1:end-2); %remove .m at the end
    end
    cname = strrep(cname, '+', '');
    cname = strrep(cname, filesep, '.');

    %append private funtions
    [~,tmp] = fileparts(caller.file);
    if ~strcmp(tmp, caller.name)
        cname = strcat(cname, '>', caller.name);
    end
else % called from command window
    cname = 'Command window';
end

info.git_repos = git_info;
info.filename = cname;
info.time = datestr(now);
info.matlab_version = version();
[~, info.hostname] = system('hostname');
info.hostname = strtrim(info.hostname);
[~, info.user] = system('whoami');
info.user = strtrim(info.user);

% all parameters currently in parent workspace
if ~exist('saveParams', 'var') || saveParams
    variableNames = evalin('caller', 'who');
    for i = 1:length(variableNames)
        info.param.(variableNames{i}) = evalin('caller', variableNames{i});
    end
end

end


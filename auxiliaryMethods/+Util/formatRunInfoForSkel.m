function str = formatRunInfoForSkel(info)
%FORMATRUNINFOFORSKEL Produces a string from a run info intended for usage
% as skeleton description.
%
% INPUT info: struct
%           see output of Util.runInfo
%
% OUTPUT str: string
%           Info string.
%
% NOTE This function avoids strcat due to the trailing whitespace behavior.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

str = ''; %#ok<*AGROW>

% filename
str = [str, sprintf('(filename: %s; ', info.filename)];

% git repos
str = [str, 'repos: '];
numRepos = length(info.git_repos);
for i = 1:numRepos
    thisRepo = info.git_repos{i};
    str = [str, sprintf('%s %s', thisRepo.remote, thisRepo.hash)]; 
    if ~isempty(thisRepo.diff)
        str = [str, ' (dirty)'];
    end
    if i < numRepos
        str = [str, ', '];
    else
        str = [str, '; '];
    end
end

% some more metainfo
str = [str, sprintf('%s %s)', info.user, info.time)];

end


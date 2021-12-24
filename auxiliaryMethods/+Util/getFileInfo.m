function info = getFileInfo(depth)
%GETFILEINFO Get metadata of the caller of function.
%
% INPUT depth: int
%           Get a higher order callig function instead of the direct
%           caller. 2 corresponds to the caller of this function. Use 3 or
%           more to return the info for higher order callers.
%           (Default: 2)
%
% OUTPUT info: struct
%           Struct with metadata about the caller of this function.
%           'name': name of the calling function
%           'pname': full package name of the calling function
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if nargin == 0
    depth = 2;
end

% get name of caller
ST = dbstack('-completenames');
if length(ST) > 1 && depth <= length(ST) % called from function or script
    caller = ST(depth); %second should the the caller of log
    idx = strfind(caller.file, '+');
    [info.dir, info.name] = fileparts(caller.file);
    if ~isempty(idx)
        [~, cname] = strtok(caller.file, '+');
        cname = cname(1:end-2); %remove .m at the end
        cname = strrep(cname, '+', '');
        cname = strrep(cname, filesep, '.');
        info.pname = cname;
    else
        info.pname = info.name;
    end
    try
        info.hash = Util.getGitHash(info.dir);
    catch
        info.hash = [];
    end
else % called from command window
    info.name = 'Command window';
    info.pname = [];
    try
        info.hash = Util.getGitHash();
    catch
        info.hash = [];
    end
end



end


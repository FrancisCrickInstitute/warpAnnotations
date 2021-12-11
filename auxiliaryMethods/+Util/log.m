function log( msg, varargin )
%LOG Utility logging function.
% INPUT msg: string
%           Message/format string. The message will be framed by the
%           current time and the function calling the log function in the
%           beginning and has a newline at the end.
%           (see formatSpec in fprintf)
%       varargin:
%           Parameters for the format specs in msg.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

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
    
    cname = strcat(cname, sprintf(':%d', caller.line));
else % called from command window
    cname = 'Command window';
end

if ~isempty(varargin)
    fprintf(['[%s] %s - ' msg '\n'], datestr(now), cname, varargin{:});
else
    fprintf(['[%s] %s - ' msg '\n'], datestr(now), cname);
end
end


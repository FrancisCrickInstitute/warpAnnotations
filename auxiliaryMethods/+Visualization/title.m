function hh = title(varargin)
%TITLE Same as the matlab title function but appends the filename and hash
% of the function that calls it to the title.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

info = Util.getFileInfo(3);
if isempty(info.hash)
    info.hash = 'n.a.';
end
varargin{1} = sprintf('%s\n(%s - %s)', varargin{1}, info.pname, info.hash);
hh = title(varargin{:});

end


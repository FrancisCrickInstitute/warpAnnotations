function switchMag(obj, mag, prefix)
%SWITCHMAG Assuming the knossos dataset is pointing to a folder in a
% resolution pyramid this helper function changes the
% magnification folder assuming that magnification folders are
% simply names with the number of the magnification in the end.
% INPUT mag: int
%           The magnification to switch to.
%       prefix: (Optional) string
%           File prefix for magnification.
%           (Default: determined using obj.getPrefix if
%           possible or replacing the string mag%d with the new
%           magnification)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

idx = strfind(obj.root, filesep);
obj.root(idx(end-1) + 1:end) = [];
obj.root = [obj.root sprintf('%d', mag) filesep];

if exist('prefix', 'var') && ~isempty(prefix)
    obj.prefix = prefix;
else
    tmp =  obj.getPrefix();
    if isempty(tmp)
        obj.prefix = regexprep(obj.prefix, 'mag\d', ...
            sprintf('mag%d', mag));
    else
        obj.prefix = tmp;
    end
end
end
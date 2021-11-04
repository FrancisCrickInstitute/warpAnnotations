function p = changePaths( p, newPath )
%CHANGEPATHS Change paths in p.local
% INPUT p: struct
%           Segmentation parameter struct.
%       newPath: string
%           Path so the segmentation main folder containing the local
%           folder.
% OUTPUT p: struct
%           Updated input.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

newPath = Util.addFilesep(newPath);

%change main folders
p.saveFolder = newPath;
p.syncFolder = '';

%change local folders
for x = 1:size(p.local, 1)
    for y = 1:size(p.local, 2)
        for z = 1:size(p.local, 3)
            curPath = fullfile(newPath, 'local', locString(x, y, z));
            p.local(x, y, z) = structfun( ...
                @(x)replacePathsIfStr(x, curPath), ...
                p.local(x, y, z), 'UniformOutput', false);
        end
    end
end

end

function str = locString(x, y, z)
str = sprintf('x%04dy%04dz%04d%s', x, y, z, filesep);
end

function x = replacePathsIfStr(x, newPath)
if ischar(x)
    fname = regexp(x, '\w*.mat$', 'match');
    if ~isempty(fname)
        x = fullfile(newPath, fname{1});
    else
        x = newPath;
    end
end
end
function p = changeFilename( p, field, filename )
%CHANGEFILENAME Change the name of a file in the local cubes of a
% segmentation struct.
% INPUT p: struct
%           Segmentation parameter struct.
%       field: string
%           The fieldname in p.local(i) that should be changed. If the
%           fieldname does not exist it is created and the saveFolder of
%           the local cube is used. Note that in this case a file
%           extensions is required.
%       filename: string
%           The new name of the corresponding file.
% OUTPUT p: struct
%           Updated input.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[~,nameNew, extNew] = fileparts(filename);
for i = 1:numel(p.local)
    if isfield(p.local(i), field) && ~isempty(p.local(i).(field))
        oldPath = p.local(i).(field);
        [pathstr, ~, ext] = fileparts(oldPath);
    else
        pathstr = p.local(i).saveFolder;
        ext = '';
    end
    if isempty(extNew)
    	newPath = [fullfile(pathstr, nameNew), ext];
    else
        newPath = [fullfile(pathstr, nameNew), extNew];
    end
    p.local(i).(field) = newPath;
end

end


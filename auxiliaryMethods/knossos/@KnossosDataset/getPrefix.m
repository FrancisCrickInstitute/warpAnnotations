function prefix = getPrefix(obj)
% GETPREFIX Get the prefix for the current knossos dataset
% based on one raw file.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

function listing = dirFolders(folder)
    listing = dir(folder);
    listing(~[listing.isdir]) = [];
    listing = listing(3:end); %remove . and ..
end

prefix = '';

list_x = dirFolders(obj.root);
if isempty(list_x)
    fprintf('Could not determine prefix automatically.\n');
    return;
end
list_yx = dirFolders(fullfile(obj.root, list_x(1).name));
list_zyx = dirFolders(fullfile(obj.root, list_x(1).name, ...
    list_yx(1).name));
for i = 1:length(list_zyx)
    tmp = dir(fullfile(obj.root, list_x(1).name, ...
        list_yx(1).name, list_zyx(i).name, ['*.' obj.ending]));
    if ~isempty(tmp)
        prefix = tmp(1).name(1:end-22);
        break
    end
end
end
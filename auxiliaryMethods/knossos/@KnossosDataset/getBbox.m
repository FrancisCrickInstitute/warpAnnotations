function bbox = getBbox(obj)
% GETBBOX Get the bounding box of the current knossos dataset
% based on the existence of knossos cubes.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

function listing = dirFolders(folder)
    listing = dir(folder);
    listing(~[listing.isdir]) = [];
    listing = listing(3:end); %remove . and ..
end

list_x = dirFolders(obj.root);
names_x = {list_x.name}';
names_y = cell(0, 1);
names_z = cell(0, 1);
for i = 1:length(list_x)
    list_yx = dirFolders(fullfile(obj.root, list_x(i).name));
    names_y = cat(1, names_y, {list_yx.name}');
    for j = 1:length(list_yx)
        list_zyx = dirFolders(fullfile(obj.root, ...
            list_x(i).name, list_yx(j).name));
        names_z = cat(1, names_z, {list_zyx.name}');
    end
end

cubes_x = sort(cellfun(@(x)str2double(x(2:end)), names_x), ...
    'ascend');
cubes_y = sort(cellfun(@(x)str2double(x(2:end)), names_y), ...
    'ascend');
cubes_z = sort(cellfun(@(x)str2double(x(2:end)), names_z), ...
    'ascend');

bbox = [cubes_x(1)*128 + 1, (cubes_x(end) + 1)*128;
        cubes_y(1)*128 + 1, (cubes_y(end) + 1)*128; ...
        cubes_z(1)*128 + 1, (cubes_z(end) + 1)*128];
end
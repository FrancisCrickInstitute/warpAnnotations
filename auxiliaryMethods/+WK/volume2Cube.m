function [X, bbox, conf] = volume2Cube( folder, bbox, dtype, confSeg )
%VOLUME2CUBE Load a volume tracing into a single matlab array.
% INPUT folder: string
%           Path to folder containing the unzipped volume tracing.
%       bbox: (Optional) [3x2] double
%           The bounding box that is loaded.
%           (Default: The whole knossos-hierarchy determined from folders
%           in the knossos hierarchy.)
%       dtype: (Optional) string
%           Type of data saved in the raw files.
%           (Default: 'uint32')
%       confSeg: (Optional) struct
%           Knossos conf to the underlying segmentation. If this is
%           provided then non-existing cubes in the volume tracings are
%           replaced by cubes from confSeg.
%           (Default: empty cubes are just zeros)
% OUTPUT X: 3d int array
%           The volume tracing as a single array.
%        bbox: [3x2] int
%           The bounding box of X.
%        conf: struct
%           Knossos configuration struct for the data.
%
% NOTE This function assumes that the input folder contains the folder
%      hierarchy 'data/1/1/' followed by the knossos cubes.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

conf.root = fullfile(folder, 'data', '1', '1');
assert(exist(conf.root, 'dir') == 7, ...
    'No dataset found in specified folder.');
conf.dtype = 'uint32';
if exist('dtype', 'var') && ~isempty(dtype)
    conf.dtype = dtype;
end

%full bbox and prefix
[bboxFull, conf.prefix] = fullBbox(conf.root);

%full bbox if not specified by user
if ~exist('bbox', 'var') || isempty(bbox)
    bbox = bboxFull;
end

%load cube
if ~exist('confSeg', 'var') || isempty(confSeg)
    X = readKnossosRoi(conf.root, conf.prefix, bbox, conf.dtype, ...
                    '', 'raw');
else
    X = readKnossosRoiRepEmpty(conf.root, conf.prefix, bbox, conf.dtype, ...
                    '', 'raw', [], confSeg.root, confSeg.prefix);
end
end

function [bbox, prefix] = fullBbox(folder)
list_x = dirFolders(folder);
names_x = {list_x.name}';
names_y = cell(0, 1);
names_z = cell(0, 1);
for i = 1:length(list_x)
    list_yx = dirFolders(fullfile(folder, list_x(i).name));
    names_y = cat(1, names_y, {list_yx.name}');
    for j = 1:length(list_yx)
        list_zyx = dirFolders(fullfile(folder, list_x(i).name, ...
            list_yx(j).name));
        names_z = cat(1, names_z, {list_zyx.name}');
        if (i == 1) && (j == 1) %get prefix
            tmp = dir(fullfile(folder, list_x(i).name, ...
                list_yx(j).name, list_zyx(1).name, '*.raw'));
            prefix = tmp(1).name(1:end-22);
        end
    end
end

cubes_x = sort(cellfun(@(x)str2double(x(2:end)), names_x), 'ascend');
cubes_y = sort(cellfun(@(x)str2double(x(2:end)), names_y), 'ascend');
cubes_z = sort(cellfun(@(x)str2double(x(2:end)), names_z), 'ascend');

bbox = [cubes_x(1)*128 + 1, (cubes_x(end) + 1)*128;
        cubes_y(1)*128 + 1, (cubes_y(end) + 1)*128; ...
        cubes_z(1)*128 + 1, (cubes_z(end) + 1)*128];
end

function listing = dirFolders(folder)
listing = dir(folder);
listing(~[listing.isdir]) = [];
listing = listing(3:end); %remove . and ..
end
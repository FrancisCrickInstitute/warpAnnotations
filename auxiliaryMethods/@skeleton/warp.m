function obj_new = warp(obj, target_dataset_name, landmarks_file)
% Convert a skeleton from a given dataset to a new dataset using the information contained in the warping/data folder
% INPUT new_dataset_name: string with webKnossos dataset name to convert skeleton to

% If landmarks file is provided it will be used to chose from multiple warpings between datasets
% Otherwise lowest weight in the warpings.csv will be used
if nargin < 3
    landmarks_file = false;
end

% Read necessary data from warping/data subfolder
datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
warpings = readtable('warping/data/warpings.csv');

% Extract values needed here from datasets table
source_dataset_name = obj.parameters.experiment.name;
source_scale = datasets{source_dataset_name, {'scale_x', 'scale_y', 'scale_z'}};
target_scale = datasets{target_dataset_name, {'scale_x', 'scale_y', 'scale_z'}};

% Determine row in warpings table to use
if landmarks_file
    row_idx = strcmp(warpings.source, source_dataset_name) & strcmp(warpings.target, target_dataset_name) & strcmp(warpings.landmarks, landmarks_file);
    row_idx_inv = strcmp(warpings.target, source_dataset_name) & strcmp(warpings.source, target_dataset_name) & strcmp(warpings.landmarks, landmarks_file);
else
    idx = find(strcmp(warpings.source, source_dataset_name) & strcmp(warpings.target, target_dataset_name));
    idx_inv = find(strcmp(warpings.target, source_dataset_name) & strcmp(warpings.source, target_dataset_name));
    % If multiple rows were found, use the one with minmal weight
    row_weights = warpings.weight(idx);
    row_inv_weights = warpings.weight(idx_inv);
    [~, idx_row] = min(row_weights);
    [~, idx_row_inv] = min(row_inv_weights);
    row_idx = false(length(warpings.source),1);
    row_idx(idx(idx_row)) = true;
    row_idx_inv = false(length(warpings.source),1);
    row_idx_inv(idx_inv(idx_row_inv)) = true;
end

if sum(row_idx) == 0 && sum(row_idx_inv) == 0
    error("warping parameters not found");
elseif sum(row_idx) == 1
    % Extract values needed here from warpings table
    source_offset = [warpings.source_offset_x(row_idx), warpings.source_offset_y(row_idx), warpings.source_offset_z(row_idx)];
    target_offset = [warpings.target_offset_x(row_idx), warpings.target_offset_y(row_idx), warpings.target_offset_z(row_idx)];
    source_size = [warpings.source_size_x(row_idx), warpings.source_size_y(row_idx), warpings.source_size_z(row_idx)];
    target_size = [warpings.target_size_x(row_idx), warpings.target_size_y(row_idx), warpings.target_size_z(row_idx)];
    source_flip = [warpings.source_flip_x(row_idx), warpings.source_flip_y(row_idx), warpings.source_flip_z(row_idx)];
    target_flip = [warpings.target_flip_x(row_idx), warpings.target_flip_y(row_idx), warpings.target_flip_z(row_idx)];
    source_mag = [warpings.source_mag_x(row_idx), warpings.source_mag_y(row_idx), warpings.source_mag_z(row_idx)];
    target_mag = [warpings.target_mag_x(row_idx), warpings.target_mag_y(row_idx), warpings.target_mag_z(row_idx)];
    if ~strcmp(warpings.landmarks{row_idx},'none')
        landmarks_file = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'warping', 'data', 'landmarks', warpings.landmarks{row_idx});
    else
        landmarks_file = 'none';
    end
    inverse = false;
elseif sum(row_idx) == 0 && sum(row_idx_inv) == 1
    % Extract values needed here from warpings table
    target_offset = [warpings.source_offset_x(row_idx_inv), warpings.source_offset_y(row_idx_inv), warpings.source_offset_z(row_idx_inv)];
    source_offset = [warpings.target_offset_x(row_idx_inv), warpings.target_offset_y(row_idx_inv), warpings.target_offset_z(row_idx_inv)];
    target_size = [warpings.source_size_x(row_idx_inv), warpings.source_size_y(row_idx_inv), warpings.source_size_z(row_idx_inv)];
    source_size = [warpings.target_size_x(row_idx_inv), warpings.target_size_y(row_idx_inv), warpings.target_size_z(row_idx_inv)];
    target_flip = [warpings.source_flip_x(row_idx_inv), warpings.source_flip_y(row_idx_inv), warpings.source_flip_z(row_idx_inv)];
    source_flip = [warpings.target_flip_x(row_idx_inv), warpings.target_flip_y(row_idx_inv), warpings.target_flip_z(row_idx_inv)];
    target_mag = [warpings.source_mag_x(row_idx_inv), warpings.source_mag_y(row_idx_inv), warpings.source_mag_z(row_idx_inv)];
    source_mag = [warpings.target_mag_x(row_idx_inv), warpings.target_mag_y(row_idx_inv), warpings.target_mag_z(row_idx_inv)];
    if ~strcmp(warpings.landmarks{row_idx_inv},'none')
        landmarks_file = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'warping', 'data', 'landmarks', warpings.landmarks{row_idx_inv});
    else
        landmarks_file = 'none';
    end
    inverse = true;
else
    error("multiple warping parameters found");
end

% 1 - Translate nodes accorindg to source magnification (do first because we assume offset and size is in given mag)
obj_new = obj.scaleNodes(1./source_mag);
% 2 - Translate nodes according to bounding box used in source dataset
obj_new = obj_new.translateNodes(-source_offset);
% 3 - Invert axes in source space
obj_new = obj_new.invertDimensions(source_size, source_flip);
% 4 - Scale nodes according to scale and mag of source dataset
obj_new = obj_new.scaleNodes(source_scale .* source_mag);
% 5 - Apply transformation found in bigwarp
obj_new = obj_new.transformNodes(landmarks_file, inverse);
% 6 - Scale nodes according to scale and mag of target dataset
obj_new = obj_new.scaleNodes(1 ./ (target_scale .* target_mag) );
% 7 - Invert axes in target space
obj_new = obj_new.invertDimensions(target_size, target_flip);
% 8 - Translate nodes according to bounding box used in target dataset
obj_new = obj_new.translateNodes(target_offset);
% 9 - Translate nodes accorindg to target magnification (do last because we assume offset and size is in given mag)
obj_new = obj_new.scaleNodes(target_mag);

% Assign new dataset name and scale to skeleton
obj_new.scale = target_scale;
obj_new.parameters.experiment.name = target_dataset_name;
obj_new.parameters.scale.x = num2str(target_scale(1));
obj_new.parameters.scale.y = num2str(target_scale(2));
obj_new.parameters.scale.z = num2str(target_scale(3));

end


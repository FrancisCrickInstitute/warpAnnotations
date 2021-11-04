function obj_new = warp(obj, target_dataset_name, landmarks_file)

if nargin < 3
    landmarks_file = false;
end

obj = transformVirtualDatasetToOriginal(obj)

datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
target_scale = datasets{target_dataset_name, {'scale_x', 'scale_y', 'scale_z'}};

obj_new = obj;
for i=1:length(obj.vertices)
    new_vertices = warp(obj.dataset, obj.vertices{i}, target_dataset_name, landmarks_file);
    obj_new.vertices{i} = new_vertices;
end

obj_new.scale = target_scale;
obj_new.dataset = target_dataset_name;

end


function obj_new = warps(obj, target_dataset_name, visualize, filename)

if nargin < 3
    visualize = false;
end
if nargin < 4
    filename = 'dependencies.png';
end

obj = transformVirtualDatasetToOriginal(obj)

datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
target_scale = datasets{target_dataset_name, {'scale_x', 'scale_y', 'scale_z'}};

obj_new = obj;
for i=1:length(obj.vertices)
    new_vertices = warps(obj.dataset, obj.vertices{i}, target_dataset_name, visualize, filename);
    obj_new.vertices{i} = new_vertices;
end

obj_new.scale = target_scale;
obj_new.dataset = target_dataset_name;

end


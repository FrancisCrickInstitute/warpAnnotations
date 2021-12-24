function nodes_new = warps(source_dataset_name, nodes, target_dataset_name, visualize, filename)

if nargin < 4
    visualize = false;
end
if nargin < 5
    filename =  'dependencies.png';
end

datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
idx_dataset = strcmp(datasets.Properties.RowNames, source_dataset_name);

% Define parameters for skeleton construct
parameters.experiment.name = source_dataset_name;
parameters.scale.x = num2str(datasets.scale_x);
parameters.scale.y = num2str(datasets.scale_y);
parameters.scale.z = num2str(datasets.scale_z);
parameters.offset.x = '0';
parameters.offset.y = '0';
parameters.offset.z = '0';

% Package everything into skeleton, warp and extract again
skel = skeleton();
skel.parameters = parameters;
skel.nodes = {nodes};
skel.nodesAsStruct{1}(:).x = nodes(:, 1);
skel.nodesAsStruct{1}(:).y = nodes(:, 2);
skel.nodesAsStruct{1}(:).z = nodes(:, 3);
skel_new = skel.warps(target_dataset_name, visualize, filename);
nodes_new = skel_new.nodes{:};

end


function nodes_new = warp(source_dataset_name, nodes, target_dataset_name, landmarks_file)

if nargin < 4
    landmarks_file = false;
end

datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
idx_dataset = strcmp(datasets.Properties.RowNames, source_dataset_name);

% Define parameters for skeleton construct
parameters.experiment.name = source_dataset_name;
parameters.scale.x = num2str(datasets.scale_x{idx_dataset});
parameters.scale.y = num2str(datasets.scale_y{idx_dataset});
parameters.scale.z = num2str(datasets.scale_z{idx_dataset});
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
skel_new = skel.warp(target_dataset_name, landmarks_file);
nodes_new = skel_new.nodes{:};

end


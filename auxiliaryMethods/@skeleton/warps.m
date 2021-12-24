function obj_new = warps(obj, target_dataset_name, visualize, filename)
% Convert a skeleton from a given dataset to a new dataset using the information contained in the warping/data folder
% INPUT new_dataset_name: string with webKnossos dataset name to convert skeleton to

if nargin < 3
    visualize = false;
end
if nargin < 4
    filename =  'dependencies.png';
end

source_dataset_name = obj.parameters.experiment.name;

% Get dependency graph
dep = constructWarpingGraph();

% Find shortest path
[shortest_path, nr_nodes] = shortestpath(dep, source_dataset_name, target_dataset_name);

% Visualize if requested
if visualize
    line_widths = 5*dep.Edges.Weight/max(dep.Edges.Weight);
    p = plot(dep,'EdgeLabel',dep.Edges.Weight,'LineWidth',line_widths, 'Interpreter', 'none');
    highlight(p, shortest_path, 'EdgeColor', 'y');
    highlight(p, shortest_path(1), 'NodeColor', 'r');
    highlight(p, shortest_path(end), 'NodeColor', 'g');
    axis off;
    saveas(gcf, filename);
end

% Apply function as used before
if isinf(nr_nodes)
    error('No path found from source to target, please check!');
else
    for step = 2:length(shortest_path)
        obj_new = obj.warp(shortest_path{step});
	obj = obj_new;
    end
end

end


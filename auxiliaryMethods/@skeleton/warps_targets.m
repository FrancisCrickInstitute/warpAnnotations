function possible_targets = warps_targets(obj)
% Returns all possible target datasets for a given skeleton given the information in the war[ing/data subfolder

% Get dependency graph of warping targets
dep = constructWarpingGraph();

% Extract values needed here from datasets table
source_dataset_name = obj.parameters.experiment.name;

d = distances(dep, source_dataset_name);
possible_targets = dep.Nodes{~isinf(d),1};

end


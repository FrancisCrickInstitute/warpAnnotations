function possible_targets = warp_targets(obj)
% Returns all possible target datasets for a given skeleton given the information in the war[ing/data subfolder

% Read necessary data from warping/data subfolder
datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
warpings = readtable('warping/data/warpings.csv');

% Extract values needed here from datasets table
source_dataset_name = obj.parameters.experiment.name;

% Check whether source dataset exists in datasets.csv
idx = strcmp(datasets.Properties.RowNames, source_dataset_name);
if sum(idx) ~= 1
    error("Dataset name specified in skeleton not found exactly 1 time in datasets.csv")
end

% Determine row in warpings table to use
possible_targets = [warpings.target(strcmp(warpings.source, source_dataset_name)); ...
                    warpings.source(strcmp(warpings.target, source_dataset_name))];
end


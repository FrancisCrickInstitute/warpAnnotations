function dep = constructWarpingGraph()

% Read necessary data from warping/data subfolder
datasets = readtable('warping/data/datasets.csv', 'ReadRowNames', true);
warpings = readtable('warping/data/warpings.csv');
% Extract values needed here from datasets table
row_names = datasets.Properties.RowNames;

% Create graph warping all dependencies
dep = graph();
for i = 1:length(row_names)
    dep = dep.addnode(row_names{i});
end
for i = 1:size(warpings,1)
    dep = dep.addedge(warpings{i,'source'}, warpings{i, 'target'}, warpings{i, 'weight'});
end

end


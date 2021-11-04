function t = nodes2Table( skel, treeIndices )
%NODES2TABLE Get a table representation of nodes.
% INPUT treeIndices: [Nx1] int or [Nx1] logical
%           Linear or logical indices for the trees of interest.
%           (Default: all trees)
% OUTPUT t: [Nx1] cell
%           Cell array of tables containing the node information.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if islogical(treeIndices)
    treeIndices = find(treeIndices);
end

t = cell(length(treeIndices), 1);
for i = 1:length(treeIndices)
    t{i} = struct2table(skel.nodesAsStruct{treeIndices(i)});
    
    %convert strings to numerical values
    t{i}{:,1:8} = cellfun(@(x)str2double(x), t{i}{:,1:8}, ...
        'UniformOutput', false);
end

end


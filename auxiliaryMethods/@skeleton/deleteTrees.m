function obj = deleteTrees(obj, treeIndices,complement)
% Delete specified trees.
% INPUT treeIndices: [Nx1] int or [Nx1] logical
%           Array with linear or logical indices of trees to delete.
%       complement: logical (default: false)
%           the complement set of trees to treeIndices would be deleted if
%           true
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% Modified: Ali Karimi <ali.karimi@brain.mpg.de>
if ~exist('complement', 'var') || isempty(complement)
    complement = false;
end

if iscolumn(treeIndices)
    treeIndices = treeIndices';
end
if islogical(treeIndices);
    treeIndices = find(treeIndices);
end
% Get the complement set of trees to the treeIndices given
if complement
    treeIndices=setdiff(1:obj.numTrees,treeIndices);
end

%get ids of deleted nodes
nodeIDs = cell2mat(cellfun(@(x)x(:,1),obj.nodesNumDataAll(treeIndices), ...
    'UniformOutput',false));

%delete tree
obj.nodes(treeIndices) = [];
obj.nodesAsStruct(treeIndices) = [];
obj.nodesNumDataAll(treeIndices) = [];
obj.thingIDs(treeIndices) = [];
obj.names(treeIndices) = [];
obj.colors(treeIndices) = [];
obj.edges(treeIndices) = [];
obj.branchpoints = setdiff(obj.branchpoints,nodeIDs);

%set largest object id if it was deleted
if any(nodeIDs == obj.largestID)
    obj.largestID = max(cellfun(@(x)max(x(:,1)),obj.nodesNumDataAll));
end

end

function obj = resetNodeIDs(obj, startID)
%Reset the IDs of all nodes of all trees.
%New node IDs will be consecutive numbers starting from one in
%the first node of the first tree and continuing along the
%current order of nodes in each tree and along the current
%order of trees in the Skeleton object.
% INPUT startID: (Optional) Integer specifying the first ID.
%                (Default: 1)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('startID','var') || isempty(startID)
    currMaxID = 0;
else
    currMaxID = startID - 1;
end

% total number of nodes
% TODO(amotta): Replace by `obj.largestID`?
[numNodes, ~] = cellfun(@size, obj.nodes);
numNodes = sum(numNodes);
oldNodeIds = nan(currMaxID + numNodes, 1);

for tr = 1:length(obj.nodes)
    numNodesInTree = size(obj.nodes{tr},1);
    newNodeIds = currMaxID + (1:numNodesInTree);
    oldNodeIds(newNodeIds) = obj.nodesNumDataAll{tr}(:,1);
    obj.nodesNumDataAll{tr}(:,1) = newNodeIds;
    idStr = arrayfun(@num2str,currMaxID + (1:numNodesInTree),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).id] = idStr{:};
    currMaxID = currMaxID + numNodesInTree;
end
obj.largestID = currMaxID;
[~, obj.branchpoints] = ismember(obj.branchpoints, oldNodeIds);
end
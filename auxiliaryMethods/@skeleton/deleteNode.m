function obj=deleteNode(obj,treeIndex,index,closeGap)
% Delete a single node of a tree.
% INPUT treeIndex: Index (not id!) of tree in skel.
%       index: Index (not id!) of node to delete.
%       closeGap: Boolean specifying whether the neighbors of
%           the deleted node should be connected to close a
%           potential gap.
% NOTE Tree might be split after deleting nodes.
% Author: Kevin Boergens <kevin.boergens@brain.mpg.de>
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>


if ~exist('closeGap','var') || isempty(closeGap)
    closeGap = false;
end

nodeId = obj.nodesNumDataAll{treeIndex}(index,1);

%find neighbors
nodeEdges = find(any(obj.edges{treeIndex} == index,2));
neighborIdx = setdiff(obj.edges{treeIndex}(nodeEdges,:),index);

%close gap by connecting neighbors with a random path
if closeGap && length(neighborIdx) > 1
    newEdges = repmat(neighborIdx',2,1);
    newEdges = reshape(newEdges(2:end-1),[length(newEdges) - 1,2]);
    obj.edges{treeIndex} = cat(1,obj.edges{treeIndex}, newEdges);
end

%delete node
obj.edges{treeIndex}(nodeEdges,:) = [];
obj.nodes{treeIndex}(index,:) = [];
obj.nodesAsStruct{treeIndex}(index) = [];
obj.nodesNumDataAll{treeIndex}(index,:) = [];

%adapt largestID
if nodeId == obj.largestID
    newMaxId = max(cellfun(@(x)max(x(:,1)), ...
        obj.nodesNumDataAll(~cellfun(@isempty,obj.nodesNumDataAll))));
    if ~isempty(newMaxId)
        obj.largestID = newMaxId;
    else
        obj.largestID = 0;
    end
end

%decrease index of all edges with index larger than the deleted
%node by one
obj.edges{treeIndex}(obj.edges{treeIndex}>index) = ...
    obj.edges{treeIndex}(obj.edges{treeIndex}>index) - 1;
end
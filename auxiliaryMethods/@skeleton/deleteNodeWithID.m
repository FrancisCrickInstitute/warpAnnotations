function skel = deleteNodeWithID(skel, id, closeGap)
%Delete the node with the specified id.
% INPUT id: Integer specifying a node id.
%       closeGap: (Optional) Logical specifying whether the
%       neighbors of the deleted node should be connected to
%       close a potential gap.
%       (Default: false)
%
% see also deleteNode
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('closeGap','var') || isempty(closeGap)
    closeGap = false;
end

[treeIdx, nodeIdx] = skel.getNodesWithIDs(id);
skel = skel.deleteNode(treeIdx,nodeIdx,closeGap);

end
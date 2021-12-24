function [hasNodesInBBox,nodesInBBox] = intersectsBbox( skel, bboxes, ...
    treeIndices, isnm )
%INTERSECTSBBOX Checks whether a skeleton has nodes in a bounding box.
% INPUT bboxes: [3x2] int or [Nx1] cell of [3x2] int
%           A bounding box or cell array of bounding boxes.
%       treeIndices:(Optional) [Nx1] int or lgoical
%           Linear or logical indices of the trees to use.
%           (Default: all trees).
%       isnm: (Optional) boolean
%           Flag that bbox is in units of nm. Scale is applied then to the
%           skeleotn nodes
% OUTPUT hasNodesInBBox: logical
%           Flag indicating whether the skeleton has at least one node in
%           one of the specified bounding boxes.
%        nodesInBBox: logical vector
%           logical vector telling which nodes where in the last bbox
%           checked
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:length(skel.nodes);
end

if ~iscell(bboxes)
    bboxes = {bboxes};
end
nodes = skel.getNodes(treeIndices);
if isnm
    nodes = bsxfun(@times, nodes, ...
        str2double(struct2cell(skel.parameters.scale))');
end
for i = 1:length(bboxes)
    nodesInBBox = all(bsxfun(@ge, nodes, bboxes{i}(:,1)') & ...
                         bsxfun(@le, nodes, bboxes{i}(:,2)'),2);                 
    hasNodesInBBox = any(nodesInBBox);
    
    if hasNodesInBBox
        break;
    end
end

end


function skel = restrictToBBox(skel, bbox, treeIndices, closeGap)
%Restrict nodes of a Skeleton to a cubic bounding box. All
%nodes outside of this bounding box will be deleted.
% INPUT bbox: [3x2] integer array containing the first and last
%             voxel of the bounding box in the respective
%             dimension.
%       treeIndices:(Optional) Vector of integer specifying the
%           trees of interest.
%           (Default: all trees).
%       closeGap: (Optional) logical
%           Flag to close gaps when deleting nodes (see also deleteNode).
%           (Default: false)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:length(skel.nodes);
end

if ~exist('closeGap', 'var') || isempty(closeGap)
    closeGap = false;
end

for tr = 1:length(treeIndices)
    if ~isempty(skel.nodes{treeIndices(tr)})
        trNodes = skel.nodes{treeIndices(tr)}(:,1:3);
        toDelNodes = any(bsxfun(@gt,trNodes, bbox(:,2)') | ...
            bsxfun(@lt,trNodes, bbox(:,1)'),2);
        skel = skel.deleteNodes(treeIndices(tr), toDelNodes, closeGap);
    end
end

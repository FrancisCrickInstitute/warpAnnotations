function [treeIdx, nodeIdx] = getNodesWithIDs(skel, ids, treeIndices)
%Get the trees and linear node indices of nodes ids.
% INPUT ids: Integer vector of node IDs.
%       treeIndices: (Optional) [Nx1] vector of linear indices
%                of trees to check for.
%                (Default: all trees)
% OUTPUT treeIdx: [Nx1] Integer vector of same length as ids
%           containing the linear tree index for the respective
%           id.
%        nodeIdx: [Nx1] Integer vector of same length as ids
%           containing the linear node index of the respective
%           id and in the respective treeIdx.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

treeIdx = zeros(length(ids),1);
nodeIdx = zeros(length(ids),1);
wasFound = false(length(ids),1);
for tr = treeIndices
    trIDs = skel.nodesNumDataAll{tr}(:,1);
    [Lia,Lib] = ismember(ids,trIDs);
    treeIdx(Lia) = tr;
    nodeIdx(Lia) = Lib(Lia);
    wasFound(Lia) = true;
    if all(wasFound)
        break
    end
end
if any(~wasFound) && skel.verbose
    warning('Not all IDs could be found in skel.');
end
end
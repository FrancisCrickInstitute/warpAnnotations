function [ nodeIdx, treeIdx ] = getClosestNode( skel, xyz, treeInds, ignoreSelf )
%Get the nodeIdx of the skeleton node closest to a point xyz the surrounding space
%   INPUT   xyz: Point in space for which the closest node should be found
%           treeInds: treeIdx oder treeIndices for which the search should
%           be performed
%           treeInds (optional): Tree indices which should be included in the search
%           (default is all)
%           ignoreSelf (optional): If a node with exactly the coordinates
%           as provided in xyz exists, ignoreSelf leads to the algorithm
%           ignoring itself and searches for the second closest node
%           (default is false)
%           WARNING: ignore itself when set true will delete the xyz node, 
%            the output nodeIdx will refer to the skeleton AFTER the deletion
%   OUTPUT  nodeIdx: NodeIdx of the node closest to xyz
%           treeIdx: The respective treeIdx to which nodeIdx relates
%
%   Author: florian.drawitsch@brain.mpg.de
%   Modified: alessandro.motta@brain.mpg.de

if ~exist('treeInds','var') || isempty(treeInds)
    treeInds = 1:size(skel.nodes,1);
end

if ~exist('ignoreSelf','var')
    ignoreSelf = 0;
end

nodes = cat(1, skel.nodes{treeInds});

if ignoreSelf
    del = sum((nodes(:,1:3) - repmat(xyz,size(nodes,1),1)).^2,2)==0;
    nodes(del,:) = [];
end

nodeNums = cellfun(@(x) size(x,1),skel.nodes);
nodeNumsSel = [0; cumsum(nodeNums(treeInds))];

allDists = bsxfun(@minus, nodes(:, 1:3), xyz);
allDists = bsxfun(@times, allDists, skel.scale);
allDists = sqrt(sum(allDists .^ 2, 2));

[~, nidx] = min(allDists);
treeIdxRel = find(nodeNumsSel >= nidx, 1) - 1;
nodeIdx = nidx - nodeNumsSel(treeIdxRel);
treeIdx = treeInds(treeIdxRel);

end
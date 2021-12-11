function bbox = getBbox(skel, treeIndices,positiveBounds)
%GETBBOX Get the bounding box for the skeleton.
% INPUT treeIndices: (Optional) [Nx1] int or logical
%           Linear or logical indices of the trees of interest.
%           (Default: all trees)
% OUTPUT bbox: [3x2] int
%           The rectangular bounding box of the skeleton.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
%         Ali Karimi <ali.karimi@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:length(skel.nodes);
end
if ~exist('positiveBounds','var') || isempty(positiveBounds)
    positiveBounds = false;
end
nodes = skel.getNodes(treeIndices);
bbox = [min(nodes, [], 1); max(nodes, [], 1)]';

% Make sure all of the bounds of the bbox are positiiive numbers
if positiveBounds
    bbox(bbox<1)=1;
end
end

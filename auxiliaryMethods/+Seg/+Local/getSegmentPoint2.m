function [segIds, points] = getSegmentPoint2(seg, bbox)
%GETSEGMENTPOINT2 Returns the point which is farthest from all membranes
%for each segment.
% INPUT seg: 3d label matrix.
%       bbox: (Optonal) Bounding box of seg which will be used to transform
%           the output points to global coordinates.
% OUTPUT segIds: [Nx1] int containing the segmentation ids in the local
%           cube.
%        points: [Nx3] int of global coordinates containing the point
%           farthest away from the membrane for each segment.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%get of segments from boundary
dist = bwdist(seg == 0);

%get pixel list for segIds
stats = regionprops(seg, 'PixelIdxList');
segId = arrayfun(@(x)~isempty(x.PixelIdxList),stats);

%get maximum dist for each segment
mPixelIdx = arrayfun(@(x)maxIdx(dist(x.PixelIdxList)),stats(segId));
mIdx = arrayfun(@(x,y)x.PixelIdxList(y),stats(segId),mPixelIdx);

%convert to global subscript
points = zeros(sum(segId),3);
[points(:,1),points(:,2),points(:,3)] = ind2sub(size(seg),mIdx);
if exist('bbox','var') && ~isempty(bbox)
    points = bsxfun(@plus,points,bbox(:,1)' - 1);
end
segIds = find(segId);
end

function idx = maxIdx(x)
[~,idx] = max(x);
end
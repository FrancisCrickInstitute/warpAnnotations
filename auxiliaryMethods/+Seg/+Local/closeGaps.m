function [ seg ] = closeGaps( seg, excludeVoxels )
%CLOSEGAPS Close gaps in a segmentation by setting all boundary voxels with
%exactly one neighboring segments ID to that ID.
% INPUT seg: 3d uint
%           3d array of integer containing a label/segmentation matrix.
%       excludeVoxels: (optional) 3d logical
%           Array of same size as seg which specified voxels which are
%           excluded as boundary voxels. Voxels that should be excluded
%           should be set to true.
%           (E.g. if only a partial segmentation is available the region
%           outside the segmentation can be masked).
%           (Default: all possible voxels are considered).
% OUTPUT seg: 3d uint
%           The updated segmentation.
%
% see also Seg.Local.applySegEquiv
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

% Pad array with a 1 voxel surround with a new unique value
borderId = max(seg(:)) + 1;
seg = padarray(seg,[1, 1, 1], borderId);
[M,N,~] = size(seg);

% Construct 26-connectivity linear indices shift for padded segmentation
vec = int32([(-M*N+[-M-1 -M -M+1 -1 0 1 M-1 M M+1]) ...
    [-M-1 -M -M+1 -1 1 M-1 M M+1] (M*N+[-M-1 -M -M+1 -1 0 1 M-1 M M+1])]);

% Find linear inidices of all wall voxel
if exist('excludeVoxels', 'var') && ~isempty(excludeVoxels)
    excludeVoxels = padarray(excludeVoxels, [1, 1, 1], 0);
    ind = int32(find(seg == 0 & ~excludeVoxels));
else
    ind = int32(find(seg==0));
end

% Find segmentation ID of all neighbours of all wall voxel (according to 26
% connectivity)
nInd = bsxfun(@plus, ind', vec');

%set voxels with exactly one neighbor to this neighbor ID
nSegId = seg(nInd);
nSegId = sort(nSegId,1);
lSegId = [false(1,size(nSegId,2)); diff(nSegId,1,1)>0];
toMerge = sum(lSegId,1) == 1;

toMergeId = nSegId(:,toMerge);
toMergeId = toMergeId(lSegId(:,toMerge));
toMerge(toMerge) = toMergeId ~= borderId;

toMergeId = nSegId(:,toMerge);
toMergeId = toMergeId(lSegId(:,toMerge));
toMergeInd = ind(toMerge);

seg(toMergeInd) = toMergeId;
seg = seg(2:end-1,2:end-1,2:end-1);
end


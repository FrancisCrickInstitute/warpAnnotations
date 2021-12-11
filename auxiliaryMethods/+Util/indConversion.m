function [ cIdx ] = indConversion( bbox, idx )
%INDCONVERSION Convert subscript indices in some global reference frame to
% local linear indices and vice versa.
% INPUT bbox: [3x2] int array of the local bounding box of the format
%           [min_x max_x; min_y max_y; min_z max_z].
%       idx: [Nx1] int array of linear indices or
%            [Nx3] int array of global subscripts.
% OUTPUT cIdx: [Nx1] int array or [Nx3] int array of converted indices.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%convert to column vector except if it is a [1x3] (could be subscript in
%this case).
if isrow(idx) && size(idx,2) ~= 3
    idx = idx';
end

if size(idx,2) == 3 %case sub2ind
    idx = bsxfun(@minus,double(idx),bbox(:,1)' - 1);
    cIdx = sub2ind(diff(bbox') + 1,idx(:,1),idx(:,2),idx(:,3));
elseif size(idx,2) == 1 %case ind2sub
    [x,y,z] = ind2sub(diff(bbox') + 1, idx);
    cIdx = bsxfun(@plus,[x, y, z],bbox(:,1)' - 1);
else
    error('Specified indices have the wrong size.');
end

end


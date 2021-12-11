function [ ind ] = sub2ind( bbox, subs )
%SUB2IND Convert 3d subscripts to linear indices from a single input array.
% INPUT bbox: [3x2] or [1x3] int
%           The bounding box for the linear indices or the size of the
%           total array as in the in-built sub2ind function.
%       subs: [Nx3] int of subscript indices in bbox.
% OUTPUT ind: [Nx1] int of linear indices wrt to bbox.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if all(size(bbox) == [3, 2])
    subs = bsxfun(@minus,double(subs),bbox(:,1)' - 1);
    ind = sub2ind(diff(bbox') + 1,subs(:,1),subs(:,2),subs(:,3));
    ind = cast(ind,Util.maxReqInt(ind));
else
    ind = sub2ind(bbox(:)', subs(:,1), subs(:,2), subs(:,3));
end

end
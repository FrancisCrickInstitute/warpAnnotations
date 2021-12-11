function bbox = bbox2WKFormat( bbox, offset, doInverse )
%BBOX2WKFORMAT Convert a bbox to WK format.
% INPUT bbox: [3x2] or [6x1] int
%           Bounding box in the format
%           [min_X, max_X; min_Y, max_Y; min_Z, max_Z]
%           or the linearized verison of it.
%       offset: (Optional) int
%           Node offset.
%           (Default: 1)
%       doInverse: (Optional) logical
%           Flag to convert a WK bounding box format to the format
%           described in bbox.
%           (Default: false)
% OUTPUT bbox: [3x2] int
%           Bounding box in the format
%           [min_X,  min_Y,  min_Z, size_x, size_y, size_z]
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('offset', 'var') || isempty(offset)
    offset = 1;
end
if ~exist('doInverse', 'var') || isempty(doInverse)
    doInverse = false;
end

if ~doInverse
    bbox = bbox - offset;
    bbox(:,2) = bbox(:,2) - bbox(:,1) + 1;
    bbox = bbox(:)';
else
    bbox = bbox(:);
    bbox(4:6) = bbox(4:6) + bbox(1:3) - 1;
    bbox = reshape(bbox, 3, 2);
    bbox = bbox + offset;
end

end


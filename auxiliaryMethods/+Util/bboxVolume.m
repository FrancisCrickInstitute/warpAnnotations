function vol = bboxVolume( bbox, vxSize )
%BBOXVOLUME Calculate the volume of a bounding box.
% INPUT bbox: [3x2] int or [Nx1] cell or [3x2] int
%           Bounding box or cell array of bounding boxes. A bounding box
%           has the format
%           [min_x max_x; min_y max_y; min_z max_z]
%       vxSize: (Optional) [1x3] double
%           Voxel size (e.g. in nm or um)
%           (Default: [1 1 1])
% OUTPUT vol: double or [Nx1] double
%           The volume for the input bbox.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~iscell(bbox)
    bbox = {bbox};
end

if exist('vxSize', 'var') && ~isempty(vxSize)
    vxSize = vxSize(:);
else
    vxSize = ones(3, 1);
end
vol = cellfun(@(x)prod(diff(x, [], 2).* vxSize), bbox);

end


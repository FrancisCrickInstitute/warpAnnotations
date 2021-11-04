function area = physicalBorderArea(borders, scale, cubeSize, minArea)
%PHYSICALBORDERAREA Calculate the border area in physical units.
%
% INPUT borders: [Nx1] cell or [Nx1] struct
%               Cell array with the linear indices of the pixels for each
%               border or
%               borderStruct array containing the field 'PixelIdxList'
%               again with the linear indices of the pixels for each
%               border.
%               In both cases, the linear indices are w.r.t. a cube of size
%               cubeSize.
%       scale: (Optional) [1x3] double
%           Voxel size in the desired physical unit for each dimension.
%           (Default: [11.24, 11.24, 28])
%       cubeSize: (Optional) [1x3] int
%           Size of the local segmentation cube to which the linear indices
%           in boders refer.
%           (Default: [512, 512, 256])
%       minArea: (Optional) double
%           Minimal area for a contact surface in um^2.
%           (Default: 5e-4 - 4 voxels in x-y-plane)
%
% OUTPUT area: [Nx1] array of double where N = length(borders) specifying the
%           physical area for each border in borders in um^2.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('scale','var') || isempty(scale)
    scale = [11.24, 11.24, 28];
end
if ~exist('cubeSize','var') || isempty(cubeSize)
    cubeSize = [512, 512, 256];
end
if ~exist('minArea','var') || isempty(minArea)
    minArea = 5e-4;
end

if isstruct(borders)
    % convert into cell array
    borders = {borders.PixelIdxList};
end

area = zeros(length(borders),1);
for i = 1:length(borders)
    [x,y,z] = ind2sub(cubeSize(:)', borders{i}(:));
    nodes = [x,y,z];
    nodes = bsxfun(@times,nodes,scale(:)');
    area(i) = Seg.Local.contactArea(nodes, [], minArea);
end

end


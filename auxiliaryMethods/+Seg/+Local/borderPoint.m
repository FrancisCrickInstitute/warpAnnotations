function [point, com] = borderPoint(borders, bbox, voxelSize)
%BORDERPOINT Similar to borderCoM but determines a point that is also part
% of the border in global coordinates.
% (see also Seg.Local.calcSegmentPoint).
% 
% INPUT borders: [Nx1] struct or struct
%           A border struct array containing the fields 'Area',
%           'PixelIdxList', 'Centroid' for each border.
%           Alternatively, the segmentation struct of a local segmentation
%           cube can be passed in to load the borders and the bbox directly
%           from a segmentation. In this case borders must contain the
%           fields 'borderFile' and 'bboxSmall' and the second input to
%           borderPoint can be empty.
%       bbox: [3x2] int
%           Global bounding box of the corresponding border struct.
%       voxelSize: (Optional) [1x3] double
%           The voxel size that is taken into account when the closest
%           point on the border surface to the com is calculated.
%
% OUTPUT point: [Nx3] int
%           For each border, point it the closest point of the border to
%           the center of mass of the border. Point is returned in global
%           coordinates (i.e. with respect to bbox).
%       com: [Nx3] int
%           The global center of mass for each border.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if isfield(borders, 'borderFile') % load files from local seg cube
    bbox = borders.bboxSmall;
    m = load(borders.borderFile);
    borders = m.borders;
end

if ~exist('voxelSize', 'var')
    voxelSize = [];
else
    voxelSize = voxelSize(:)';
end

siz = diff(bbox, [], 2) + 1;

% get com
[com, com_global] = Seg.Local.borderCoM(borders, bbox);

% get closest point of border to com
point = arrayfun(@(x, y) ...
    nnsearch(com(x, :), y.PixelIdxList, siz, voxelSize), ...
    (1:length(borders))', borders, 'uni', 0);
point = cell2mat(point);

point = bsxfun(@plus, point, bbox(:,1)' - 1);
com = com_global;

end

function point = nnsearch(com, lcoords, siz, voxelSize)

coords = Util.indToSubMat(siz, lcoords);
if isempty(voxelSize) || all(voxelSize == 1)
    idx = knnsearch(coords, com);
else
    idx = knnsearch(bsxfun(@times, coords, voxelSize), ...
                    bsxfun(@times, com, voxelSize));
end
point = coords(idx, :);

end
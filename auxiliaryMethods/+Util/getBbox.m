function Y = getBbox( X, bbox )
%GETBBOX Index a matrix using a bounding box of the form
% [min_x, max_x; min_y, max_y; ...]
% INPUT X: nd array
%       bbox: [Nx2] int array
%           Bounding box of the form [min_x, max_x; min_y, max_y; ...] with
%           minimal and maximal coordinates for each dimension.
% OUTPUT Y: nd array
%           The resulting array.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

S = arrayfun(@(x)bbox(x,1):bbox(x,2),1:size(bbox,1), ...
    'UniformOutput', false);
s.type = '()';
s.subs = S;
Y = subsref(X, s);

end


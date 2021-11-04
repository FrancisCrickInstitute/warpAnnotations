function [ idx ] = lneigh26( siz )
%LNEIGH26 Return the relative linear indices of the 26 neighbors of a point
% in 3d space i.e. (refPoint + idx) gives the coordinates of the 26
% neighbors of refPoint.
% INPUT siz: [3x1] int size of the cube.
% OUTPUT idx: [1x26] int containing the relative indices of the 26
%           neighbors of a point.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

x = siz(1);
p = siz(1)*siz(2);
idx = [(-p+[-x-1, -x, -x+1, -1, 0, 1, x-1, x, x+1]), ...
           [-x-1, -x, -x+1, -1, 1, x-1, x, x+1], ...
        (p+[-x-1, -x, -x+1, -1, 0, 1, x-1, x, x+1])];

end


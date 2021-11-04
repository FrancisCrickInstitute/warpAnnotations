function pts = getPointsInBall( c, r )
%GETPOINTSINBALL Get the coordinates of all points in a ball of radius r
%centered on c.
% INPUT c: [1x3] array of integer specifying the center coordinates of the
%           ball.
%       r: Double specifying the radius of the ball.
% OUTPUT pts: [Nx3] array of integer containing all the points within the
%           ball of radius r around c.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

r2 = ceil(r);
[xx, yy, zz] = meshgrid(-r2:r2,-r2:r2,-r2:r2);
S = sqrt(xx.^2+yy.^2+zz.^2) <= r;
props = regionprops(S, 'PixelList');
pts = props.PixelList - (r2 + 1);
pts = bsxfun(@plus,c,pts);

end
function points = getPointsOnSphere(c, r)
%POINTSONSPHERE Return all points (coordinates in 3D space) that constitute a
%sphere of radius around the center c.
%
%   INPUT
%     c: [1x3] coordinate vector defining the center of the sphere.
%     r: integer or float definining the radius of the sphere.
%
%   OUTPUT
%     points: [Nx3] array of point coordinates that constitute the sphere.
%

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

  if ~isrow(c)
    c = c';
  end

  if(r < 1)
    points = [1 1 1];
  else
    [xx, yy, zz] = meshgrid(1:2*r+1,1:2*r+1,1:2*r+1);
    S = sqrt((xx-r-1).^2+(yy-r-1).^2+(zz-r-1).^2)<=r;
    props = regionprops(S, 'PixelList');
    points = props.PixelList;
  end
  points = repmat(c-r, size(points, 1), 1) + points;

end

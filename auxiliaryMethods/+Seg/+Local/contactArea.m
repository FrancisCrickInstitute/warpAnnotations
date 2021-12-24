function area = contactArea( nodes, scale, minArea )
%CONTACTAREA Contact area for a surface in 3d given by a set of nodes.
% INPUT nodes: [Nx3] single
%           List of points constituting the border surface.
%       scale: (Optional) [1x3] single
%           Voxel size to scale the nodes in nm.
%           (Default: [1, 1, 1])
%       minArea: (Optional) double
%           Minimal area in case points are collinear.
%           (Default: 5e-4)
% OUTPUT area: double
%           Contat area for the surface represented by nodes in um^2.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% Based on code by Manuel Berning <manuel.berning@brain.mpg.de>

if nargin > 1 && ~isempty(scale)
    nodes = bsxfun(@times, double(nodes), scale(:)');
else
    nodes = double(nodes);
end

if nargin < 3
    minArea = 5e-4;
end

if size(nodes,1) > 3
    [~, score] = pca(nodes);
    try
        k = convhull(score(:,1),score(:,2));
        area = polyarea(score(k,1),score(k,2))/1e6;
    catch
        %collinear points
        area = minArea;
    end
else
    % Lower cutoff
    area = minArea;
end

end


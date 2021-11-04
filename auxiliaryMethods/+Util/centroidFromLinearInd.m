function [ cen ] = centroidFromLinearInd( ind, siz )
%CENTROIDFROMLINEARIND Calculate the centroid for a set of linear
%indices in 3D.
% INPUT ind: [Nx1] array of linear indices.
%       siz: [1x3] array of integer specifying the size of the cube to
%           which the indices in ind refer.
% OUTPUT cen: Centroid of the indices in ind.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if isrow(ind)
    ind = ind';
end

[x,y,z] = ind2sub(siz,ind);
cen = mean([x,y,z]);


end


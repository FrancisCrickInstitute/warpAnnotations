function [ kl_values, outOfBBox ] = readKnossosCoords( kl_parfolder, ...
    kl_fileprefix, kl_coords, classT, kl_filesuffix, ending, cubesize, ...
    suppressWarnings )
%READKNOSSOSCOORDS Read single coordinates from a knossos hierarchy.
% INPUT kl_coords: [Nx3] numerical array containing the coordinates of
%           interest.
%       suppressWarning: (Optional) Logical flag to suppress warnings from
%           readKnossosCube.
%       bbox: (Optional) [3x2] array specifying the a bounding box in
%           global coordinates of the form
%           [minX, maxX; minY, maxY; minZ, maxZ]
%       for other inptus see readKnossosCube
% OUTPUT kl_values: [NxM] array of type classT containing the values at the
%           specified coordinates. The second dimension corresponds to
%           channels.
%        outOfBBox: [Nx1] array of logical indicating that the knossos-cube
%           for the respective coordinate does not exist.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('classT','var') || isempty(classT)
    classT = 'uint8';
end
if ~exist('ending','var') || isempty(ending)
    ending = 'raw';
end
if ~exist('kl_filesuffix','var') || isempty(kl_filesuffix)
    kl_filesuffix = '';
end
if ~exist('cubesize','var') || isempty(cubesize)
    cubesize = [128, 128, 128, 1];
else
    cubesize(end+1:4) = 1;
end
if exist('suppressWarnings','var') && suppressWarnings
    warning('off','auxiliaryMethods:readKnossosCube');
end

cubeIdx = floor(bsxfun(@times,(kl_coords - 1),1./cubesize(1:3)));

%sort coordinates by knossos cubes
[uCubeIdx, ~, ic] = unique(cubeIdx,'rows');
[sId, idxIc] = sort(ic);
sortedCoords = kl_coords(idxIc,:);
ooBbox = false(size(sortedCoords,1),1);
groupIdx = find([true; diff(sId,1) > 0; true]);

values = zeros(size(kl_coords,1),cubesize(4),classT);
for i = 1:size(uCubeIdx,1)
    currCube = readKnossosCube(kl_parfolder, kl_fileprefix, ...
        uCubeIdx(i,:), [classT '=>' classT], kl_filesuffix, ...
        ending, cubesize, false);
    if isempty(currCube)
        %cube does not exist
        ooBbox(groupIdx(i):(groupIdx(i+1)-1)) = true;
    else
        %get coordinates for current cube
        currCoords = bsxfun(@minus, ...
            sortedCoords(groupIdx(i):(groupIdx(i+1) - 1),:), ...
            uCubeIdx(i,:).*cubesize(1:3));
        currCoords = sub2ind(cubesize,currCoords(:,1), ...
            currCoords(:,2),currCoords(:,3));
        %index at currCoords for all channels
        values(groupIdx(i):(groupIdx(i+1)-1),:) = currCube( ...
            bsxfun(@plus,currCoords, ...
            (0:cubesize(4)-1).*prod(cubesize(1:3))));
    end
end

%resort values
[~,reIdx] = sort(idxIc);
values = values(reIdx,:);
outOfBBox = ooBbox(reIdx);
kl_values = -ones(size(kl_coords,1),cubesize(4));
kl_values(~outOfBBox,:) = values(~outOfBBox,:);

end

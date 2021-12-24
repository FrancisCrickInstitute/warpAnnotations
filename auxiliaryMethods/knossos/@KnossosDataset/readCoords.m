function [values, oob] = readCoords(obj, coords)
%READCOORDS Wrapper for readKnossosCoords
% INPUT coords: [Nx3] int
%           Array of 3d coordinates in the rows.
% see also readKnossosCoords
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[ values, oob ] = readKnossosCoords( obj.root, obj.prefix, ...
    coords, obj.dtype, obj.suffix, obj.ending, obj.cubesize, ...
    false);
end
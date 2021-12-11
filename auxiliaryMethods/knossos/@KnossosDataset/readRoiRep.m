function data = readRoiRep(obj, bbox, confRep)
% READROIREP Wrapper for readKnossosRoiRepEmpty.
% INPUT bbox: [3x2] int array
%           Bounding box in the form
%           [x_min x_max; y_min y_max; z_min z_max]
%       conf: KnossoDataset object or struct
%           Object that is used to replace non-existing cubes.
%           see also readKnossosRoiRepEmpty
% see also readKnossosRoi
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

assert(strcmp(obj.dtype, confRep.dtype));
data = readKnossosRoiRepEmpty(obj.root, obj.prefix, bbox, ...
    obj.dtype, obj.suffix, obj.ending, [], ...
    confRep.root, confRep.prefix);
end
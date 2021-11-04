function obj = setBbox( obj, bbox, toWkFormat )
%SETBBOX Set a bounding box in the skeleton that is written to the
%parameter section and is displayed in WK.
% The bbox is written to the field skel.parameters.userBoundingBox.
% If the input bbox is empty then the corresponding field is deleted.
% INPUT bbox: [6x1] int
%           Bbox in the format
%           [min_X,  min_Y,  min_Z, size_x, size_y, size_z]
%           or such that the linearized version of bbox is in this format,
%           e.g. [min_X, size_x; min_Y, size_y; min_Z, size_z]
%       toWKFormat: (Optional) logical
%           Flag to indicate that the bounding box is first transformed via
%           WK.bbox2WKFormat. In this case the node offset of the skeleton
%           is also applied to the bounding box.
%           (Default: false)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('toWkFormat', 'var') || isempty(toWkFormat)
    toWkFormat = false;
end

if isempty(bbox)
    if isfield(obj.parameters, 'userBoundingBox')
        obj.parameters = rmfield(obj.parameters, 'userBoundingBox');
    end
else
    if toWkFormat
        bbox = WK.bbox2WKFormat(bbox, obj.nodeOffset);
    end
    obj.parameters.userBoundingBox.topLeftX = num2str(bbox(1));
    obj.parameters.userBoundingBox.topLeftY = num2str(bbox(2));
    obj.parameters.userBoundingBox.topLeftZ = num2str(bbox(3));
    obj.parameters.userBoundingBox.width = num2str(bbox(4));
    obj.parameters.userBoundingBox.height = num2str(bbox(5));
    obj.parameters.userBoundingBox.depth = num2str(bbox(6));
end



end


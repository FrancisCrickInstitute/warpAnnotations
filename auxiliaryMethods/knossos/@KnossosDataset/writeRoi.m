function writeRoi(obj, bbox, data)
% WRITEROI Wrapper for writeKnossosRoi.
% INPUT bbox: [3x2] int or [3x1] int
%           Bounding box of the form [x_min; y_min; z_min]
%           In case a [3x2] bounding box is supplied only the
%           first column is used.
% see also writeKnossosRoi
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%check input data
if ~isa(data,obj.dtype)
    error('Data type needs to be %s.', obj.dtype);
end

%adapt bbox input for writeKnossosRoi
if iscolumn(bbox)
    bbox = bbox';
elseif all(size(bbox) == [3, 2])
    if ~all((diff(bbox, [], 2)' + 1) == size(data))
        error(['The specified bounding box does not fit' ...
            ' the size of the data.']);
    end
    bbox = bbox(:,1)';
end

writeKnossosRoi(obj.root, obj.prefix, bbox, ...
    data, obj.dtype, obj.suffix, [], obj.cubesize);
end
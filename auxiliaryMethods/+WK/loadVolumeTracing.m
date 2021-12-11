function [ data ] = loadVolumeTracing( file, bbox, dtype )
%LOADVOLUMETRACING Load a volume tracing that was downloaded via the api
%into matlab.
% INPUT file: string
%           Path to volume tracing binary file.
%       bbox: [3x2] int
%           The bounding box of the volume tracing (last index including,
%           i.e. default matlab bbox).
%       dtype: (Optional) string
%           Datatype of the volume tracing.
%           (Default: 'uin32')
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('dtype','var') || isempty(dtype)
    dtype = 'uint32';
end

siz = diff(bbox, [], 2)' + 1;

data = WK.readRaw(file, siz, dtype);


end


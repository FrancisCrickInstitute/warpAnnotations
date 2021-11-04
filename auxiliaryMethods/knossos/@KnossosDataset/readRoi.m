function data = readRoi(obj, bbox, mag, verbose)
% READROI Wrapper for readKnossosRoi.
% INPUT bbox: [3x2] int
%           Bounding box in the form
%           [x_min x_max; y_min y_max; z_min z_max]
%       mag: (Optonal) int
%           Current magnification. Set 0 to determine automatically from
%           root name.
%           (Default: 1)
%       verbose: (Optional) logical
%           Flag to see warnings from readKnossosRoi
%           (Default: false)
% see also readKnossosRoi
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('verbose', 'var') || isempty(verbose)
    verbose = false;
end

if exist('mag', 'var')
    if mag > 1
        bbox = bbox./mag;
    elseif mag == 0
        idx = strfind(obj.root, filesep);
        mag = str2double(obj.root(idx(end-1) + 1:end-1));
        bbox = bbox./mag;
    else
        error('Invalid magnification specified.');
    end
end

if ~verbose
    warning('off', 'all');
end
data = readKnossosRoi(obj.root, obj.prefix, bbox, obj.dtype, ...
    obj.suffix, obj.ending, obj.cubesize);
warning('on', 'all');
end

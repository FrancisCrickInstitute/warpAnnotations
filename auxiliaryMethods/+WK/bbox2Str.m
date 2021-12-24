function [ sBbox ] = bbox2Str( bbox, downloadFormatting )
%BBOX2STR Convert a bounding box from the standard format in the pipeline
%to a string that can be copied to wk.
% INPUT bbox: [3x2] int or [1x6] int
%           Bounding box in the format [minX, maxX; minY, maxY; minZ, maxZ]
%           or the linearized version of it.
%       downloadFormatting: (Optional) logical
%           Flag indicating whether the output should have the format for
%           api.data.downloadRawDataCuboid:
%           "[minX, minY, minZ], [maxX + 1, maxY + 1, maxZ + 1]"
%           (Default: false)
% OUTPUT sBbox: string
%           Bounding box as string in the format
%           "minX, maxX, minY, width, height, depth"
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('downloadFormatting', 'var') || isempty(downloadFormatting)
    downloadFormatting = false;
end

bbox = reshape(bbox, 3, 2);
if downloadFormatting
    bbox(:,2) = bbox(:,2) + 1;
    sBbox = arrayfun(@num2str, bbox(:), 'UniformOutput', false);
    sBbox = ['[' strjoin(sBbox(1:3), ', '), '], [' ...
        strjoin(sBbox(4:6), ', ') ']'];
else
    bbox(:,1) = bbox(:,1) - 1;
    bbox(:,2) = bbox(:,2) - bbox(:,1);
    sBbox = arrayfun(@num2str, bbox(:), 'UniformOutput', false);
    sBbox = strjoin(sBbox, ', ');
end


end
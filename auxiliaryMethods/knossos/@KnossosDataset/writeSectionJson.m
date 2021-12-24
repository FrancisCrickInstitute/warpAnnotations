function writeSectionJson(obj, bbox, resolutions, filepath)
% WRITESECTIONJSON Generate the section.json.
% INPUT bbox: (Optional) [3x2] int
%           Dataset bounding box.
%           (Default: determined using obj.getBbox())
%       resolutions: (Optional) [Nx1] int
%           Array of resolutions.
%           (Default: 1)
%       filepath: (Optional) string
%           Path to output file
%           (Default: 'section.json'in parent of obj.root)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('bbox', 'var') || isempty(bbox)
    data.bbox = obj.getBbox()';
else
    data.bbox = bbox';
end

if ~exist('resolutions', 'var') || isempty(resolutions)
    data.resolutions = {1};
else
    data.resolutions = num2cell(resolutions);
end

if ~exist('filepath', 'var') || isempty(filepath)
    idx = strfind(obj.root, filesep);
    filepath = obj.root;
    filepath(idx(end-1) + 1:end) = [];
    filepath = fullfile(filepath, 'section.json');
end

writeJson(filepath, data);

end
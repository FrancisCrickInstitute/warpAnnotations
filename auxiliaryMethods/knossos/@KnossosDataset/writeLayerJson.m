function writeLayerJson(obj, typ, filepath, maxId)
% WRITELAYERJSON Generate the layer.json.
% INPUT typ: (Optional) string
%           Typ string (e.g. 'color' or 'segmentation')
%           (Default: 'color' for uint8 data and 'segmentation'
%           for uint32 data)
%       filepath: (Optional) string
%           Path to output file
%           (Default: 'layer.json'in parent of obj.root )
%       maxId: (Optional) int
%           Maximal id for segmentations.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('typ', 'var') || isempty(typ)
    switch obj.dtype
        case 'uint8'
            data.typ = 'color';
        case 'uint32'
            data.typ = 'segmentation';
        otherwise
            error('No default typ for dtype %s.', obj.dtype);
    end
else
    data.typ = typ;
end
data.class = obj.dtype;
if exist('maxId', 'var') && ~isempty(maxId)
    data.largestValue = maxId;
end
if ~exist('filepath', 'var') || isempty(filepath)
    idx = strfind(obj.root, filesep);
    filepath = obj.root;
    filepath(idx(end-1) + 1:end) = [];
    filepath = fullfile(filepath, 'layer.json');
end
writeJson(filepath, data);
end
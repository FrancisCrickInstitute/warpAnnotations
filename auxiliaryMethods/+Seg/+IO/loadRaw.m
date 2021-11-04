function raw = loadRaw(p, bbox, border, normalize)
%LOADRAW Load raw data using a segmentation parameter struct.
% INPUT p: struct
%           Segmentation parameter struct.
%       bbox: [3x2] int or scalar int
%           Bounding box or integer of local segmentation cube for which
%           the raw data is loaded for bboxSmall.
%       border: (Optional) [3x1] int
%           Additional border around bbox that is added on each side of the
%           specified bbox or bboxSmall respectively.
%       normalize: (Optional) logical
%           Normalize the raw data using p.norm.
%           (Default: no normalization)
% OUTPUT raw: 3d uint8
%           The loaded raw data.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if isscalar(bbox)
    bbox = p.local(bbox).bboxSmall;
end
if exist('border', 'var') && ~isempty(border)
    border = border(:);
    bbox = bsxfun(@plus, bbox, [-border, border]);
end

raw = loadRawData(p.raw, bbox);

if exist('normalize', 'var') && normalize
    raw = p.norm.func(raw);
end
end 

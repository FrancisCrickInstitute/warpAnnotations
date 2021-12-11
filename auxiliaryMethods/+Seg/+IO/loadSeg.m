function seg = loadSeg( p, bbox )
%LOADSEG Load segmentation data using a segmentation parameter struct.
% INPUT p: struct
%           Segmentation parameter struct.
%       bbox: [3x2] int or scalar int
%           Bounding box or integer of local segmentation cube for which
%           the raw data is loaded for bboxSmall.
% OUTPUT raw: 3d uint8
%           The loaded raw data.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~isfield(p.seg, 'ending')
    p.seg.ending = 'raw';
end
if ~isfield(p.seg, 'dtype')
    p.seg.dtype = 'uint32';
end

if isscalar(bbox)
    bbox = p.local(bbox).bboxSmall;
end

% NOTE(amotta): Blame me!
assert(strcmp(p.seg.dtype, 'uint32'));
assert(strcmp(p.seg.ending, 'raw'));

seg = loadSegDataGlobal(p.seg, bbox);

end


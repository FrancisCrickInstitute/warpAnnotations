function [ seg, segments ] = applySegEquivToSeg( eClasses, seg, segments )
%APPLYSEGEQUIVTOSEG Apply a segment equivalence relation to seg.
% INPUT eClasses: [Nx1] cell
%           Each entry contains an [Mx1] int array specifying the segment
%           IDs which should be merged.
%           Note that each equivalence class should be sorted in ascending
%           order. An equivalence class is represented by its first element
%           which thus should be the smallest one.
%       seg: 3d array of integer containing a segmentation.
%       segments: (Optional) struct
%           Segments struct with the fields 'Id' and 'PixelIdxList'
%           containing the linear pixels of all segment IDs in seg.
%           (Default: will be calculated)
% OUTPUT seg: The input segmentation with all segment IDs of an equivalence
%           class set to the first ID of that class.
%        segments: struct
%           The segments struct.
%
% see also Seg.Local.applySegEquiv, Seg.Local.applySegEquivToIDs
%
% NOTE This function is equivalent to using Seg.Local.applySegEquivToIDs
%      for seg but much faster due to the precalculated segment pixel
%      indices.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('segments', 'var') || isempty(segments)
    segments = calculateSegments(seg);
end
ids = [segments(:).Id];
ids = ids(:);

for i = 1:length(eClasses)
    curSegments = ismember(ids, eClasses{i});
    seg(cell2mat({segments(curSegments).PixelIdxList}')) = eClasses{i}(1);
end

end

function segments = calculateSegments(seg)
segments = regionprops(seg, seg, 'PixelIdxList', 'MinIntensity');
segments(arrayfun(@(x)isempty(x.PixelIdxList),segments)) = [];
[segments.Id] = segments.MinIntensity;
segments = rmfield(segments,'MinIntensity');
end


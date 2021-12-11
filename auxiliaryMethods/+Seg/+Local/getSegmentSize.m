function segVolume = getSegmentSize( seg, idList )
%GETSEGSIZE Get the size of the segments in a local cube.
% INPUT seg: The segments struct from p.local(i).segmenFile or the segments
%            array from p.local(i).segFile
%       idList: List of segment ids for which the size is calculated.
%               Repeated IDs are allowed.
%               (e.g. [segments(1:10).Ids])
% OUTPUT segVolume: Vector of integers containing the volume of the
%                   corresponding segment in idList.
%
% NOTE If seg contains the segments struct, then this function will return
%      the segment size in bboxSmall. If seg is the actual segmentation array,
%      then the size of the segment in bboxBig is calculated. Since this
%      requires to find all segment voxels in seg this might take much longer.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%get segIDs array if seg is struct
if isstruct(seg)
    segIDs = [seg(:).Id];
end

%handles repeated IDs
[uIDList,~,ic] = unique(idList);

%determine segment size
vol = zeros(length(uIDList),1,'uint32');
if isstruct(seg) %segmentFile
    for uid = 1:length(uIDList)
        vol(uid) = length(seg(segIDs == uIDList(uid)).PixelIdxList);
    end
else %segFile
    for uid = 1:length(uIDList)
        vol(uid) = sum(subsref(seg == uIDList(uid),struct('type','()','subs',{{':'}})));
    end
end
segVolume = vol(ic);

end

function segSize = getGlobalSegmentSize( p )
%GETGLOBALSEGMENTSIZE Get the size of all segments.
% INPUT p: Segmentation parameter struct.
% OUTPUT segSize: Vector of integer containing the size of the segment with
%                 global id i in the i-th row.
%
% NOTE This function calculates the segment size in bbox small.
%
% NOTE This function currently assumes that global segment ids are saved in
%      p.local(i).segmentsFile.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

segSize = zeros(0,1,'uint32');

fprintf('[%s] Calculating segments in local cubes.\n',datestr(now));
tic
for i = 1:numel(p.local)
    m = load(p.local(i).segmentFile);
    segments = m.segments;
    segIDs = [segments(:).Id];
    segSize(segIDs) = Seg.Local.getSegmentSize(segments, segIDs);
    Util.progressBar(i, numel(p.local));
end

end

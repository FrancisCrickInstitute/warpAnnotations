function com = getGlobalCoMList( p )
%GETGLOBALCOMLIST Get the center of mass for all segments.
% INPUT p: Segmentation parameter struct.
% OUTPUT com: [Nx3] array of integer. The i-th row contains the com for the
%             segment with id i.
%
% NOTE This function loads the com calculated on bbox small.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

com = zeros(0,3,'uint16');
fprintf('[%s] Calculating CoMs in local cubes.\n',datestr(now));
tic
%load com for local segments
for i = 1:numel(p.local)
    m = load(p.local(i).segmentFile);
    segments = m.segments;
    segIDs = [segments(:).Id];
    tileSize = diff(p.local(i).bboxSmall, [], 2) + 1;
    localCoMs = Seg.Local.getSegmentCoM(segments, segIDs, tileSize);
    bboxSmall = p.local(i).bboxSmall;
    localCoMs = uint16(bsxfun(@plus,localCoMs,bboxSmall(:,1)' - 1));
    com(segIDs,:) = localCoMs;
    Util.progressBar(i, numel(p.local));
end


end

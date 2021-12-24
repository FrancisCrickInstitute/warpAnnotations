function [ segSizeMapped ] = applyMappingToSegmentSize( segSize, mapping )
%APPLYMAPPINGTOSEGMENTSIZE Calculate the segment size after mapping.
% INPUT segSize: Vector of integer containing the size of the segment with
%       	global id i in the i-th row.
%       mapping: Mapping of global correspondences (see 
%           Seg.Global.getGlobalMapping)
% OUTPUT segSizeMapped: The segment size of mapped seg IDs.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

fprintf('[%s] Combining segments via mapping.\n',datestr(now));
%sum segment size for local segments which are mapped to same segment
segSizeMapped = zeros(max(mapping),1,'like',segSize);
for i = 1:length(segSize)
    newID = mapping(i);
    segSizeMapped(newID) = segSizeMapped(newID) + segSize(i);
end

end


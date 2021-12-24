function [ ids ] = applySegEquivToIDs( eClasses, ids )
%APPLYSEGEQUIVTOIDS Apply a segment equivalence relation to ids.
% INPUT eClasses: [Nx1] cell array. Each entry contains an [Mx1] numerical
%           array specifying the segment IDs which should be merged.
%       ids: Array of arbitrary size of integer IDs.
% OUTPUT ids: Updated input array where all elements of an equivalence
%           class are replaced by the first representative in eClasses.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

for i = 1:length(eClasses)
    %replace all ids of equivalence class by first entry in eClass
    toReplace = ismember(ids,eClasses{i});
    ids(toReplace) = eClasses{i}(1);
end


end


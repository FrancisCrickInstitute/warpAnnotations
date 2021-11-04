function idToEClass = eClassLookup(eClasses, maxId, toSparse)
%ECLASSLOOKUP Create a lookup table to find the equivalence class for a given
% id.
% INPUT eClasses: [Nx1] cell array of integer cell arrays (equivalence classes).
%       maxId: (Optonal) Integer specifying the maximal possible Id.
%           (Default: maximum Id found in eClasses)
%       toSparse: (Optional) logical
%           Flag whether to convert to output to a sparse array.
%           (Default: true - for compatibility)
% OUTPUT idToEClass: Sparse array of size(maxId,1) where the i-th entry contains
%           the equivalence class for the i-th id. If an id is not present in
%           eClasses the index will be 0.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('toSparse','var') || isempty(toSparse)
    toSparse = true;
end

i = double(cell2mat(eClasses));
if ~exist('maxId','var') || isempty(maxId)
    maxId = max(i);
end
maxId = double(maxId);

%create sparse cell array with eClassIdx for corresponding ids
idx = 1:length(eClasses);
idx = repelem(idx,cellfun(@length,eClasses));
if toSparse
    idToEClass = sparse(i(i <= maxId),1,idx(i <= maxId),maxId,1);
else
    idToEClass = zeros(maxId, 1);
    idToEClass(i(i <= maxId)) = idx(i <= maxId);
end

end

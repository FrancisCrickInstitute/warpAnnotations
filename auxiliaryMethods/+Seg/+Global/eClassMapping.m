function mapping = eClassMapping( eClasses, availIds )
%ECLASSMAPPING Create a mapping for segment ids into the ids of an
%agglomerations.
% INPUT eClasses: [Nx1] cell of [Mx1] int
%           Equivalence classes of segment ids.
%       availIds: [Nx1] int
%           All available ids. If it is a scalar then it will be assumed
%           that 1:availIds are available.
% OUTPUT mapping: [Nx1] int
%           Array of length(max(availIds)) such that newId = mapping(id).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if isscalar(availIds)
    tmp = setdiff(1:availIds, cell2mat(eClasses));
else
    tmp = setdiff(availIds, cell2mat(eClasses));
end
mapping = zeros(max(availIds(:)), 1, 'uint32');
mapping(tmp) = tmp;
mapping(cell2mat(eClasses)) = repelem(cellfun(@(x)x(1), eClasses), ...
    cellfun(@length, eClasses));

end


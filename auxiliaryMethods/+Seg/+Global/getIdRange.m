function idRange = getIdRange( p )
%GETIDRANGE Get the range of global segment IDs for each local cube.
% INPUT p: Segmentation parameter struct.
% OUTPUT idRange: [Nx2] array of integer.
%           Each row contains the minimal and maximal segment ID for the
%           corresponding linear index in p.local.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

idRange = zeros(numel(p.local),2);
for i = 1:numel(p.local)
    idRange(i,:) = Seg.Local.segIdRange(p.local(i));
end

end
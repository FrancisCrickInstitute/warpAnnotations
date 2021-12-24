function idRange = segIdRange( pCube )
%SEGIDRANGE Get the range of segment IDs for a local cube.
% INPUT pCube: A local segmentation cube parameter struct
%           (e.g. p.local(i)).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

segIds = Seg.Local.getSegmentIds(pCube);
idRange = [min(segIds), max(segIds)];

end


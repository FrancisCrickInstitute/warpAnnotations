function lut = buildLUT( maxSegId, agglos, aggloIds )
%BUILDLUT Build a lookup table for agglos.
% INPUT maxSegId: (Optional) int
%           The maximal segment id. If the maximal segment id in agglos is
%           smaller than this then the output will be enlarged up to this
%           id.
%       agglos: [Nx1] cell
%           Cell array of integer ids. Cells should be non-overlapping.
%       aggloIds: [Nx1] array
%           Array of integers with agglomerate ids. By default, the
%           segments in agglomerate `i` are represented by the id `i`. That
%           is, `aggloIds = 1:numel(agglos)`. Other ids can be specified as
%           long as they are all non-zero and unique.
% OUTPUT lut: [Nx1] int
%           Mapping containing the linear index of the agglo at the
%           locations of the segment id, i.e. lut(segId) = aggloIdx.
% Author: Alessandro Motta <alessandro.motta@brain.mpg.de>
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if exist('aggloIds', 'var') ...
        && ~isempty(aggloIds)
    % sanity checks
    assert(all(aggloIds));
    assert(numel(agglos) == numel(aggloIds));
    assert(numel(agglos) == numel(unique(aggloIds)));
else
    % default value
    aggloIds = 1:numel(agglos);
end

lut = zeros(maxSegId, 1);
lut(cell2mat(agglos)) = repelem( ...
    aggloIds, cellfun(@numel, agglos));

end
function segIds = getSegmentIdsOfNodes(param, coords, nhood)
    % GETSEGMENTIDS
    %   Gets the global segment IDs for each of the points
    %   specified in coords.
    %
    % IMPORTANT
    %   In contrast to getSkelSegmentIDs, this function is
    %   ready to be used with the pipeline repository!
    %
    % param
    %   Parameter structure thath was produced with
    %   run configuration.m
    %
    % coords
    %   Nx3 matrix of doubles. Each row corresponds to a
    %   position vector in global coordinates.
    %
    % nhood
    %   Scalar that indicates the size of the neighbour-
    %   hood. If, for example,
    %
    %   * nhood = 0, only the segment IDs at the specified
    %     locations are returned,
    %   * nhood = 26, the segment IDs for the specified
    %     locations and the 26 neighbouring voxels are returned.
    %
    % segIds
    %   Nx(1 + nhood) array of global segment IDs. The entries
    %   are zero if the point lies on a border and -1 if the
    %   point is outside the segmented bounding box.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~exist('nhood', 'var') || isempty(nhood)
        nhood = 0;
    end
    
    box = param.bbox;
    
    sideLen = (nhood + 1) ^ (1 / 3);
    assert(sideLen == round(sideLen));
    
    off = cell(1, 1, 1, 3);
   [off{:}] = ndgrid(1:sideLen, 1:sideLen, 1:sideLen);
    off = cell2mat(off) - (sideLen - 1) / 2 - 1;
    off = reshape(off, 1, [], 3);
    
    coords = reshape(coords, [], 1, 3);
    coords = reshape(coords + off, [], 3);
    
    % build mask for valid coords
    mask =  ...
        all(bsxfun(@ge, coords, box(:, 1)'), 2) ...
      & all(bsxfun(@le, coords, box(:, 2)'), 2);
    
    % prepare output
    coordCount = size(coords, 1);
    segIds = nan(coordCount, 1);
    
    % lookup segment IDs for valid coordinates
    segIds(mask) = Seg.Global.getSegIds(param, coords(mask, :));
    
    % set invalid coordinates to minus one
    segIds(~mask) = -1;
    
    segIds = reshape(segIds, [], 1 + nhood);
end

function points = calcSegmentPoint(seg)
    % points = calcSegmentPoint(seg, segIds)
    %   This function calculates the three indices of the
    %   point with highest distance from the borders for
    %   for each segment.
    %
    % seg
    %   Three-dimensional segmentation value. The segments
    %   must be numbered consecutively starting from one.
    %   Zero represents the borders.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % build boundary-distance matrix
    dist = bwdist(buildMask(seg));
    
    % find voxels for each segment
    segProps = regionprops(seg, 'PixelIdxList');
    segCount = numel(segProps);
    
    % find maximum in relative indices
    maxIdx = arrayfun(@(p) ...
        getMaxIdx(dist(p.PixelIdxList)), segProps);
    
    % convert to absolute indices
    maxIdx = arrayfun(@(p, idx) ...
        p.PixelIdxList(idx), segProps, maxIdx);
    
    % build output
    segSize = size(seg);
    points = nan(segCount, 3);
    
    [points(:, 1), points(:, 2), points(:, 3)] = ...
        ind2sub(segSize, maxIdx);
end

function mask = buildMask(seg)
    mask = (seg == 0);
    
    % NOTE
    % bwdist will calculate the Euclidean distance to the
    % closest non-zero voxel. However, bwdist is not aware
    % of the matrix borders. Let's add artificial non-zero
    % values at border.
    mask(1, :, :) = true; mask(end,  : ,  : ) = true;
    mask(:, 1, :) = true; mask( : , end,  : ) = true;
    mask(:, :, 1) = true; mask( : ,  : , end) = true;
end

function maxIdx = getMaxIdx(distVals)
    [~, maxIdx] = max(distVals);
end

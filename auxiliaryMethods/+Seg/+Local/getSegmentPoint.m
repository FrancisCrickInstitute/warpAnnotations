function [segIds, points] = getSegmentPoint(param, cubeIdx)
    % [segIds, points] = getSegmentPoint(param, cubeIdx)
    %   This function reduces each and every segment in the
    %   specificed segmentation cube to a single point. This
    %   point is guaranteed to lie within the segment.
    %
    % param
    %   Parameter structure produced by setParameterSettings
    %
    % cubeIdx
    %   Linear index of a segmentation cube
    %
    % segIds
    %   Nx1 vector with global IDs of all segment in the cube
    %
    % points
    %   Nx3 matrix. The entries of row i represent the point
    %   to which the segment segIds(i) was reduced.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    %   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    
    % load segmentation data
    cubeParam = param.local(cubeIdx);
    box = cubeParam.bboxSmall;
    
    % find segment IDs
    seg = loadSegDataGlobal(param.seg, box);
   [seg, segIds] = Seg.Local.fromGlobal(seg);
    
    % find local coordinates
    points = Seg.Local.calcSegmentPoint(seg);
    assert(size(points, 1) == numel(segIds));
    
    % to global coordinates
    points = bsxfun( ...
        @plus, points, box(:, 1)') - 1;
end

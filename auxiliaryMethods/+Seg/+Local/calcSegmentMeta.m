function meta = calcSegmentMeta(seg)
    % meta = calcSegmentMeta(seg)
    %   Builds the meta information structure for the given
    %   segmentation volume.
    %
    % seg
    %   A three-dimensional segmentation volume where the
    %   different segments are numbered consecutively star-
    %   ting from one. Zero is reserved for border voxels.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    props = regionprops( ...
        seg, seg, 'MinIntensity', ...
        'Area', 'BoundingBox', 'Centroid');
    
    %% prepare output
    meta = struct;
    
    %% segment IDs
    meta.segIds = [props.MinIntensity];
    meta.segIds = meta.segIds(:);
    
    %% voxel count
    meta.voxelCount = [props.Area];
    meta.voxelCount = meta.voxelCount(:);
    
    %% bounding box
    meta.box = cat(3, props.BoundingBox);
    meta.box = reshape(meta.box, [], 6, numel(props));
    meta.box(:, 4:6, :) = ...
        meta.box(:, 1:3, :) ...
      + meta.box(:, 4:6, :) - 1;
  
    meta.box = round(meta.box);
    meta.box = reshape(meta.box, 3, 2, []);
    meta.box = meta.box([2, 1, 3], :, :);
    
    %% centroid
    meta.centroid = squeeze(cat(3, props.Centroid));
    meta.centroid = reshape(meta.centroid, 3, []);
    meta.centroid = meta.centroid([2, 1, 3], :);
    
    %% center point
    meta.point = Seg.Local.calcSegmentPoint(seg);
    meta.point = permute(meta.point, [2, 1]);
end

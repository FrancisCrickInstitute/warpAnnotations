function meta = getSegmentMeta(param, cubeIdx)
    % meta = getSegmentMeta(param, cubeIdx)
    %   This function calculates a bunch of segment-meta
    %   information, such as the centroids, the voxel counts,
    %   the bounding boxes, the central points and the cube
    %   indices.
    %
    %   All of these values can be computed right after the
    %   segmentation step.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    cubeParam = param.local(cubeIdx);
    cubeOff = cubeParam.bboxSmall(:, 1);
    
    % load segmentation
    box = cubeParam.bboxSmall;
    seg = loadSegDataGlobal(param.seg, box);
   [seg, segIds] = Seg.Local.fromGlobal(seg);
    
    %% run main code
    meta = Seg.Local.calcSegmentMeta(seg);
    assert(numel(segIds) == numel(meta.segIds));
    
    % convert to global coordinates
    meta.centroid = bsxfun(@plus, meta.centroid, cubeOff - 1);
    meta.box = bsxfun(@plus, meta.box, cubeOff - 1);
    meta.point = bsxfun(@plus, meta.point, cubeOff - 1);
    
    % fill in segment IDs
    meta.segIds = segIds(meta.segIds);
    meta.maxSegId = max(meta.segIds);
    
    if isfield(param,'mask') && isfield(param,'checkborder') && param.checkborder
        % dilate inverted mask to find segments at border
        mask = readKnossosRoi(param.mask.root, [param.seg.prefix,'_mask'], box, 'uint8');
        mask = uint8(~mask)*255;
        mask = imdilate(mask,strel('ball',1,1,0));
        meta.atborder = false(numel(meta.segIds),1);
        meta.atborder(setdiff(seg(mask > 1),0)) = true;
    end
        
    % add cube index
    meta.cubeIdx = repmat(cubeIdx, numel(meta.segIds), 1);
end

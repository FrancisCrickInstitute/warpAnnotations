function sizes = getSegToSizeMap(param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    maxSegId = Seg.Global.getMaxSegId(param);
    
    metaFile = fullfile(param.saveFolder, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'voxelCount');
    
    sizes = zeros(maxSegId, 1, 'like', meta.voxelCount);
    sizes(meta.segIds) = meta.voxelCount;
end
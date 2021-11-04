function cubeIds = getSegToCubeMap(param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    maxSegId = Seg.Global.getMaxSegId(param);
    
    metaFile = fullfile(param.saveFolder, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'cubeIdx');
    
    cubeIds = zeros(maxSegId, 1, 'like', meta.cubeIdx);
    cubeIds(meta.segIds) = meta.cubeIdx;
end
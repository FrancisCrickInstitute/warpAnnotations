function boxes = getSegToBoxMap(param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    maxSegId = Seg.Global.getMaxSegId(param);
    
    metaFile = fullfile(param.saveFolder, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'box');
    
    boxes = nan(3, 2, maxSegId);
    boxes(:, :, meta.segIds) = meta.box;
end
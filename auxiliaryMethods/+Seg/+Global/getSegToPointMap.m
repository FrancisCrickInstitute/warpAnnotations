function points = getSegToPointMap(param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    maxSegId = Seg.Global.getMaxSegId(param);
    
    metaFile = fullfile(param.saveFolder, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'point');
    
    points = nan(maxSegId, 3);
    points(meta.segIds, :) = transpose(meta.point);
end
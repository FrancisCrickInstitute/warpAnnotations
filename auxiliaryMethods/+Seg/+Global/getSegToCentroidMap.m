function centroids = getSegToCentroidMap(param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    maxSegId = Seg.Global.getMaxSegId(param);
    
    metaFile = fullfile(param.saveFolder, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'centroid');
    
    centroids = nan(maxSegId, 3);
    centroids(meta.segIds, :) = transpose(meta.centroid);
end
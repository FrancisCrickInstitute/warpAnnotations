function probs = getSegToSpineHeadProbMap(param)
    % probs = getSegToSpineHeadProbMap(param)
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    maxSegId = Seg.Global.getMaxSegId(param);
    probs = zeros(maxSegId, 1);
    
    preds = load(fullfile(param.saveFolder, 'segmentPredictions.mat'));
    probs(preds.segId) = preds.probs(:, preds.class == 'spinehead');
end
function skel = addMissedSegsToSkel(param, nmlPath, box, segCount)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    rootDir = param.saveFolder;
    
    % find missed segIds
    known = NML.Dense.load(param, nmlPath);
    missedSegIds = NML.Dense.findMissedSegIds(param, known.segId, box);
    
    % limit to given number of segments
    if ~exist('segCount', 'var'); segCount = numel(missedSegIds); end;
    missedSegIds = missedSegIds(1:min(segCount, numel(missedSegIds)));
    
    % load coordinates
    data = load(fullfile(rootDir, 'segmentMeta.mat'), 'segIds', 'point');
    [~, cols] = ismember(missedSegIds, data.segIds);
    coords = transpose(data.point(:, cols));
    
    % add nodes to skeleton
    skel = skeleton(nmlPath);
    skel = skel.addNodesAsTrees(coords);
end
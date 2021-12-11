function [segIds, vxCount] = findMissedSegIds(param, knownSegIds, box)
    % [segIds, vxCount] = findMissedSegIds(param, knownSegIds, box)
    %   Build a list of all segment IDs contained in the bounding box |box|
    %   which were missed by |knownSegIds| (e.g., nodes.segId). The segment
    %   IDs are sorted in order of decreasing segment volumne.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    seg = loadSegDataGlobal(param.seg, box);
    
    % count voxels
    [segIds, ~, seg] = unique(seg);
    vxCount = accumarray(seg, 1);
    
    % sort by volume
    [vxCount, sortIds] = sort(vxCount, 'descend');
    segIds = segIds(sortIds);
    
    % remove collected
    skipSegIds = [0; knownSegIds(:)];
    skipMask = ismember(segIds, skipSegIds);
    
    vxCount(skipMask) = [];
    segIds(skipMask) = [];
end
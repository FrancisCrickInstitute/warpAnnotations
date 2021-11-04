function cubeIds = getCubeIds(param, segIds)
    % cubeIds = getCubeIds(param, segIds)
    %   This function returns the linear indices of the segmentation cubes
    %   containing the segments in `segIds`.
    %
    % param
    %   Parameter structure
    %
    % cubeIds
    %   Matrix with the linear indices of the segmentation cube containing
    %   the segments in `segIds`. `cubeIds` has the same size as `segIds`.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    % load meta data
    rootDir = param.saveFolder;
    metaFile = fullfile(rootDir, 'segmentMeta.mat');
    meta = load(metaFile, 'segIds', 'cubeIdx');
    
    % find correct rows
    [found, row] = ismember(segIds, meta.segIds);
    
    assert(all(found));
    cubeIds = meta.cubeIdx(row);
end

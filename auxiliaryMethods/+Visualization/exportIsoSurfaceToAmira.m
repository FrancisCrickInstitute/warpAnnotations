function exportIsoSurfaceToAmira(param, isoSurfs, outFile)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    % fix anisotropy
    voxelSize = param.raw.voxelSize;
    voxelSize = reshape(voxelSize, 1, 3);
    
    % prepare input data
    if ~iscell(isoSurfs); isoSurfs = {isoSurfs}; end
    if ~iscell(outFile); outFile = {outFile}; end
    
    assert(numel(isoSurfs) == numel(outFile));
    fileCount = numel(isoSurfs);
    
    for curFileIdx = 1:fileCount
        curIsos = isoSurfs{curFileIdx};
        
        if ~iscell(curIsos); curIsos = {curIsos}; end
        isoCount = numel(curIsos);

        for curIsoIdx = 1:isoCount
            curIsos{curIsoIdx}.vertices = bsxfun( ...
                @times, curIsos{curIsoIdx}.vertices, voxelSize);
        end

        % default color
        meshColours = repmat([1, 0, 0], isoCount, 1);
        Visualization.writePLY( ...
            curIsos, meshColours, outFile{curFileIdx});
    end
end

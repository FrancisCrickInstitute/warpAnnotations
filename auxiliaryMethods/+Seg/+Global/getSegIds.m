function segIds = getSegIds(param, coords, cubeSize)
    % segIds = getSegIds(param, coords)
    %   This function looks up the segment IDs at all points
    %   specified in 'coords'. It uses the KNOSSOS cubes for
    %   this purpose and is thus much faster than loading the
    %   same data from MATLAB files.
    %
    % param
    %   Parameter structure
    %
    % coords
    %   Nx3 matrix. Each row contains the coordinates of
    %   a point whose segment ID will be looked up.
    %
    % segIds
    %   Nx1 vector. The entry segIds(i) contains the global
    %   segment IDs found at coordinate coords(i, :).
    %
    % cubeSize
    %   Optional 1x3 vector. Determines the chunk size in
    %   which nodes are process. Smaller sizes are more RAM
    %   efficient, but large chunk sizes reduce the number of
    %   data load operations and can thus speed up the process.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~exist('cubeSize', 'var') || isempty(cubeSize)
        cubeSize = [128, 128, 128];
    else
        assert(isequal(size(cubeSize), [1, 3]));
    end
    
    % build cube ids
    cubeIds = getCubeIds(cubeSize, coords);
    [uniCubeIds, ~, uniCubeRows] = unique(cubeIds, 'rows');
    
    % look up cubes
    coordCount = size(coords, 1);
    uniCubeCount = size(uniCubeIds, 1);
    
    % prepare output
    segIds = zeros(coordCount, 1);
    
    tic;
    for curIdx = 1:uniCubeCount
        % build bounding box
        curCubeIds = uniCubeIds(curIdx, :);
        curCubeMin = 1 + (curCubeIds - 1) .* cubeSize;
        curCubeMax = curCubeMin + cubeSize - 1;
        % load segmentation
        curCubeBox = [curCubeMin(:), curCubeMax(:)];
        curSegData = loadSegDataGlobal(param.seg, curCubeBox);
        
        % build linear indices
        curRowMask = uniCubeRows == curIdx;
        curCoords = coords(curRowMask, :);
        curCoords = bsxfun(@minus, curCoords, curCubeMin - 1);
        
        % look up segment IDs
        curSegIds = curSegData(sub2ind(cubeSize, ...
            curCoords(:, 1), curCoords(:, 2), curCoords(:, 3)));
        segIds(curRowMask) = curSegIds;
        
        Util.progressBar(curIdx, uniCubeCount);
    end
end

function cubeIds = getCubeIds(cubeSize, coords)
    % sanity check
    assert(all(coords(:) > 0));
    
    % to cube ids
    cubeIds = ceil(bsxfun( ...
        @times, coords, 1 ./ cubeSize));
end
function cellIso = buildIsoSurface(param, segIds, varargin)
    % BUILDISOSURFACE This function builds a single
    % iso-surface for agiven set of segments. In order to do
    % so, it first computes the super-mask on a per-cube
    % level, then calculates the iso-surfaces and finally
    % joints them together.
    % 
    % Check out the following blog post for some background
    % information and high-level documentation:
    %   mhlablog.net/2016/02/11/whole-cell-isosurface-extraction/
    %
    % BuildIsoSurface also accepts a set of optional key-
    % value pairs for further configuration:
    %
    % * reduce: Scalar in the range from zero to one. It
    %   determines the degree to which the isosurface is
    %   simplified.
    %
    % NOTE This function does not correct for voxel anisotropy.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % parse optional inputs
    optIn = struct;
    optIn.smoothWidth = 2;
    optIn.smoothSizeHalf = 2;
    optIn.distVol = [];
    
    optIn = Util.modifyStruct(optIn, varargin{:});
    optIn.smoothSizeFull = 1 + 2 * optIn.smoothSizeHalf;
    
    % add padding
    %   1 pixel for overlap
    %   N pixels for filtering
    optIn.padSize = 1 + optIn.smoothSizeHalf;
    
    % find cubes
    uniCubeIdx = unique(Seg.Global.getCubeIds(param, segIds));
    uniCubeCount = numel(uniCubeIdx);
    
    % decide whether to run on cluster
    if isfield(optIn, 'onCluster')
        if isequal(optIn.onCluster, 'dynamic')
            optIn.onCluster = (uniCubeCount > 10);
        else
            assert(islogical(optIn.onCluster));
        end
    else
        optIn.onCluster = false;
    end

    % prepare run
    tic();
    disp('Computing isosurfaces...');
    
    if isfield(optIn, 'onCluster') && optIn.onCluster
        jobArgs = arrayfun(@(i) {{i}}, 1:uniCubeCount);
        jobArgsShared = {param, optIn, segIds, uniCubeIdx};
        
        % compute isosurfaces on cluster
        job = Cluster.startJob( ...
            @forCube, jobArgs, ...
            'cluster',{'taskConcurrency',100},...
            'sharedInputs', jobArgsShared, ...
            'name', mfilename(), ...
            'numOutputs', 1);
        Cluster.waitForJob(job);
        cubeIsos = fetchOutputs(job);
    else
        % compute isosurfaces locally
        cubeIsos = cell(uniCubeCount, 1);
        
        for curIdx = 1:uniCubeCount
            cubeIsos{curIdx} = forCube( ...
                param, optIn, segIds, uniCubeIdx, curIdx);

            % show progress
            Util.progressBar(curIdx, uniCubeCount);
        end
    end
    
    % assemble iso
    cellIso = struct;
    cellIso.faces = zeros(0, 3);
    cellIso.vertices = zeros(0, 3);
    
    curVertOff = 0;
    for curIdx = 1:numel(cubeIsos)
        curCubeIso = cubeIsos{curIdx};
        cellIso.vertices = [cellIso.vertices; curCubeIso.vertices];
        cellIso.faces = [cellIso.faces; (curCubeIso.faces + curVertOff)];
        curVertOff = curVertOff + size(curCubeIso.vertices, 1);
    end
    
    % status update!
    disp('Removing duplicate vertices...');
    
    % remove duplicate vertices
   [cellIso.vertices, ~, uniVertIds] = ...
        unique(cellIso.vertices, 'rows');
    cellIso.faces = uniVertIds(cellIso.faces);
end

function cubeIso = forCube(param, optIn, segIds, uniCubeIdx, idx)
    % default value for early returns
    cubeIso = struct;
    cubeIso.faces = zeros(0, 3);
    cubeIso.vertices = zeros(0, 3);
    
    % determine bouding box
    cubeBox = uniCubeIdx(idx);
    cubeBox = param.local(cubeBox).bboxSmall;
    
    cubeBox(:, 1) = cubeBox(:, 1) - optIn.padSize;
    cubeBox(:, 2) = cubeBox(:, 2) + optIn.padSize;
    cubeBox = double(cubeBox);
    
    if ~isempty(optIn.distVol)
        % calculate distance-based mask
        distMask = wkwLoadRoi(optIn.distVol.rootDir, cubeBox);
        distMask = distMask < optIn.distVol.thresh;
        if ~any(distMask(:)); return; end
    else
        distMask = [];
    end
    
    % build agglomerate mask
    cubeMask = loadSegDataGlobal(param.seg, cubeBox);
    cubeMask = ismember(cubeMask, segIds);
    
    if ~isempty(distMask)
        % apply distance mask, if present
        cubeMask = cubeMask & distMask;
    end

    % apply smoothing
    cubeMask = smooth3( ...
        cubeMask, 'gaussian', ...
        optIn.smoothSizeFull, optIn.smoothWidth);

    % get rid of border effects
    cubeMask = cubeMask( ...
        (1 + optIn.smoothSizeHalf):(end - optIn.smoothSizeHalf), ...
        (1 + optIn.smoothSizeHalf):(end - optIn.smoothSizeHalf), ...
        (1 + optIn.smoothSizeHalf):(end - optIn.smoothSizeHalf));

    % accordingly fix the bounding box
    cubeBox(:, 1) = cubeBox(:, 1) + optIn.smoothSizeHalf;
    cubeBox(:, 2) = cubeBox(:, 2) - optIn.smoothSizeHalf;

    % make blunt ends
    uniCubeIds = Util.indToSubMat( ...
        size(param.local), uniCubeIdx);
    uniCubeIdsMin = min(uniCubeIds, [], 1);
    uniCubeIdsMax = max(uniCubeIds, [], 1);
    cubeIds = uniCubeIds(idx, :);
    
    if cubeIds(1) == uniCubeIdsMin(1); cubeMask(1, :, :)   = 0; end
    if cubeIds(2) == uniCubeIdsMin(2); cubeMask(:, 1, :)   = 0; end
    if cubeIds(3) == uniCubeIdsMin(3); cubeMask(:, :, 1)   = 0; end
    if cubeIds(1) == uniCubeIdsMax(1); cubeMask(end, :, :) = 0; end
    if cubeIds(2) == uniCubeIdsMax(2); cubeMask(:, end, :) = 0; end
    if cubeIds(3) == uniCubeIdsMax(3); cubeMask(:, :, end) = 0; end

    % compute isosurface
    cubeIso = isosurface(cubeMask, 0.2);

    % apply reduction, if request
    if isfield(optIn, 'reduce') && optIn.reduce < 1
        cubeIso = reducepatch(cubeIso, optIn.reduce);
    end
    
    % fix empty isosurfaces
    cubeIso.faces = reshape(cubeIso.faces, [], 3);
    cubeIso.vertices = reshape(cubeIso.vertices, [], 3);
    
    % fix order of coordinates
    % dammit MATLAB!
    cubeIso.vertices = cubeIso.vertices(:, [2, 1, 3]);

    % correct position
    cubeIso.vertices = bsxfun( ...
        @plus, cubeIso.vertices, cubeBox(:, 1)');
end

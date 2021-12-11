function boxes = getGlobalBoxes(param)
    cubes = param.local;
    cubeCount = numel(cubes);

    % prepare output
    boxes = uint32(zeros(0, 3, 2));

    for curIdx = 1:cubeCount
        curCube = cubes(curIdx);
        curCubeDir = curCube.saveFolder;

        % load boxes
        curMaskFile = [curCubeDir, 'segMasks.mat'];
        curMasks = load(curMaskFile, 'segIds', 'boxGlobal');

        % fill in output
        boxes(curMasks.segIds, :, :) = ...
            curMasks.boxGlobal;
    end

end


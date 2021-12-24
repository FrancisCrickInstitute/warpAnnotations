function mask = buildMaskLowRes(param, segIds, blockSize)
    % mask = buildMaskLowRes(param, segIds, blockSize)
    %   Builds a low-resolution mask for the whole data set.
    %
    % Note
    %   Here, the mask does not contain logical values, but
    %   singles in the range from zero to one.
    %
    % How it works
    %   1 For each voxel in the original segmentation, label
    %     it as true if its global segment ID is in the list
    %     segIds. Label as false otherwise.
    %
    %   2 Do the down-sampling by calculating the mean value
    %     over blocks of size 'blockSize'.
    %
    % param
    %   Parameter structure produced by setParameterSettings
    % 
    % segIds
    %   Set of global IDs of the segments to be collected
    %
    % blockSize
    %   1x3 vector. Optional. Each voxel in the output 'mask'
    %   will correspond to a block of size 'blockSize' in the
    %   original segmentation data.
    % 
    %   Default value: [8, 8, 4]
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    cubes = param.local;
    cubeCount = numel(cubes);
    
    % default values
    if ~exist('blockSize', 'var')
        blockSize = [8, 8, 4];
    end
    
    % collect data in parallel
    cluster = Cluster.config( ...
        'priority', 0, 'memory', 6, 'time', '0:10:00');
    
    job = createJob(cluster);
    job.Name = mfilename();
    
    % write common input to file
    inData = struct;
    inData.segParam = param.seg;
    inData.segIds = segIds;
    inData.blockSize = blockSize;
    
    inFile = [tempname(Util.getTempDir()), '.mat'];
    Util.saveStruct(inFile, inData);
    
    % create tasks
    taskParam = arrayfun(@(curIdx) { ...
        inFile, cubes(curIdx).bboxSmall}, ...
        1:cubeCount, 'UniformOutput', false);
    createTask(job, @jobMain, 1, taskParam);
    
    submit(job);
    wait(job);
    
    % build output
    mask = fetchOutputs(job);
    mask = reshape(mask, size(cubes));
    mask = cell2mat(mask);
    
    % remove temp file
    delete(inFile);
end

function mask = jobMain(inFile, box)
    % load inputs
    load(inFile);

    % sanity check
    boxSize = box(:, 2) - box(:, 1) + 1;
    assert(all(mod(boxSize, blockSize(:)) == 0));
    
    % load segmentation data
    data = loadSegDataGlobal(segParam, box);
    
    % convert to binary high-res mask
    mask = ismember(data, segIds);
    
    % build output
    mask = reduce(mask, blockSize);
end

function mask = reduce(mask, bs)
    % convert to single
    sz = size(mask);
    mask = single(mask);
    
    % compute mean along all three dimensions
    mask = mean(reshape(mask, sz(1), sz(2), bs(3), []), 3);
    mask = mean(reshape(mask, sz(1), bs(2), []), 2);
    mask = mean(reshape(mask, bs(1), []), 1);
    
    % build output
    mask = reshape(mask, sz ./ bs);
end

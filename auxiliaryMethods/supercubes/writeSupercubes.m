function writeSupercubes(inParam, bbox, magsToWrite, outParam, isSeg)
    % Write subsampled data, it is assumed root points to magnification one
    % power of 2 less than the first mag to write & all magnifications
    % increase by a power of 2
    %
    % Written by
    %   Manuel Berning <manuel.berning@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % Decide which function to use for downsampling
    % .. and read data once
    if isSeg
        downsamplingFunction = @mode; 
        data = loadSegDataGlobal(inParam, bbox);
    else
        downsamplingFunction = @median; 
        data = loadRawData(inParam, bbox);
    end
 
    % Write multiple resoultions
    curStartPos = bbox(:, 1)';
    curOutParam = outParam;
    
    for i = 2:size(magsToWrite, 1)
        % Make the size of raw divisibale by 2 in each dimension (by
        % padding at upper limit)
        data( ...
            (end + 1):(end + mod(size(data, 1), 2)), ...
            (end + 1):(end + mod(size(data, 2), 2)), ...
            (end + 1):(end + mod(size(data, 3), 2))) = 0;
        
        % When subsampling a segmentation replace 0s with NaNs so that
        % @mode does not return 0 mode (which will dominate in larger
        % magnifications otherwise)
        if isSeg
            % Make sure that segment IDs are accurately represented after
            % the conversion from uint32 to double.
            assert(max(data(:)) < flintmax('double'));
            
            data = double(data);
            data(data == 0) = NaN; 
        end
        
        % Do the subsampling
        curPoolVol = magsToWrite(i, :) ./ magsToWrite(i - 1, :);
        data = nlfilter3(data, downsamplingFunction, curPoolVol);
        
        % Reverse NaN replacement, will only happen if all voxel in 2x2x2
        % neighboorhood are NaN (= zero before replacement above) not yet
        % sure whether this case can occur, as we only have 1 voxel thick
        % borders according to 27 connectivity?
        if isSeg
           data(isnan(data)) = 0;
           data = uint32(data);
        end
        
        % Update root
        curMagStr = sprintf('%d-%d-%d', magsToWrite(i, :));
        curOutParam.root = fullfile(outParam.root, curMagStr);
        curOutParam.root(end + 1) = filesep;
        
        % Update prefix
        if isfield(curOutParam, 'prefix')
            curOutParam.prefix = ...
                regexprep(outParam.prefix, '(\d+)$', curMagStr);
        end
        
        % Update lower coordinate to start writing in same position
        % according to K/wK convention (but different magnification)
        curStartPos = (curStartPos - 1) ./ curPoolVol + 1;
        
        % Write downsampled version
        if isSeg
            saveSegDataGlobal(curOutParam, curStartPos, data);
        else
            saveRawData(curOutParam, curStartPos, data);
        end
    end

end


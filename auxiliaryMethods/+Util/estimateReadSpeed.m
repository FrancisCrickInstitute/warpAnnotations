function data = estimateReadSpeed(param, numRep)
    % data = estimateReadSpeed(param, numRep)
    %   Estimates the effective speed of reading raw data (i.e.,
    %   it includes the overhead of the MATLAB run-time, the wK
    %   cubes reading, etc.)
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    data = table;
    data.deltaT = nan(numRep, 1);
    data.numBytes = nan(numRep, 1);
    
    for curIdx = 1:numRep
        [data.deltaT(curIdx), data.numBytes(curIdx)] ...
            = doIt(param.raw, param.bbox);
    end
    
    % calculate speed in bytes per second
    data.speed = data.numBytes ./ data.deltaT;
end

function [deltaT, numBytes] = doIt(raw, box)
    minSize = 128;
    maxSize = 1024;
    
    % build random box
    boxSize = 1 + diff(box, 1, 2) - minSize;
    boxSize = max(1, min(boxSize, maxSize - minSize));
    boxSize = minSize - 1 + arrayfun(@randi, boxSize);
    
    boxOff = (1 + diff(box, 1, 2)) - (boxSize - 1);
    boxOff = box(:, 1) - 1 + arrayfun(@randi, boxOff);
    
    box = [boxOff, boxOff + boxSize - 1];
    
    tZero = tic();
    loadRawData(raw, box);
    
    % measure
    deltaT = toc(tZero);
    numBytes = prod(diff(box, 1, 2) + 1);
end
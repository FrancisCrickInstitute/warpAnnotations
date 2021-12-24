function maskFunc = getSegIdMask(param)
    % mask = getSegIdMask(param)
    %   Builds a logical mask (of infinite size) in which
    %   entry j is set to true iff the segment with global
    %   ID j is present in the data set.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    % find list of all segments in data set
    uniSegIds = Seg.Global.getUniqueSegIds(param);
    
    % find lower and upper limits
    minSegId = uniSegIds(1);
    maxSegId = uniSegIds(end);
    
    % build lookup table
    lut = false(maxSegId - minSegId + 1, 1);
    lut(1 + uniSegIds - minSegId) = true;
    
    % build output closure
    maskFunc = @thisMaskFunc;
    
    function mask = thisMaskFunc(segIds)
        mask = false(size(segIds));
        
        checkMask = ...
            (segIds >= minSegId) ...
          & (segIds <= maxSegId);
        mask(checkMask) = lut( ...
            1 + segIds(checkMask) - minSegId);
    end
end

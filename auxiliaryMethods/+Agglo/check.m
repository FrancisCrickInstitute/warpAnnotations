function check(agglos)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    posMask = cellfun( ...
        @(ids) all(ids > 0), agglos);
    assert( ...
        all(posMask), ['Non-positive segment ', ...
        'ID in agglomerate %d'], find(~posMask, 1));
    
    maxSegId = getMaxSegId(agglos);
    segLUT = Agglo.buildLUT(maxSegId, agglos);
    
    for curIdx = 1:numel(agglos)
        curAggloIds = segLUT(agglos{curIdx});
        if all(curAggloIds == curIdx); continue; end
        
        error( ...
            'Agglomerate %d overlaps with %s', ...
            curIdx, num2str(setdiff(curAggloIds, curIdx)));
    end
end

function maxSegId = getMaxSegId(agglos)
    maxSegId = ~cellfun(@isempty, agglos);
    maxSegId = max(cellfun(@max, agglos(maxSegId)));
    if isempty(maxSegId); maxSegId = 0; end
end

function segIds = fromSuperAgglo(superAgglos, forceCellOutput)
    % segIds = fromSuperAgglo(superAgglos)
    %   Converts a super-agglomerate into a regular agglomerate (i.e., an
    %   equivalence class of segment IDs).
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~exist('forceCellOutput', 'var') || isempty(forceCellOutput)
        forceCellOutput = false;
    end
    
    % Convert super-agglomerates to segment equivalence classes
    segIds = arrayfun(@core, superAgglos, 'UniformOutput', false);
    if isscalar(segIds) && ~forceCellOutput; segIds = segIds{1}; end
end

function segIds = core(superAgglo)
    segIds = superAgglo.nodes(:, 4);
    segIds = segIds(~isnan(segIds));
    segIds = unique(segIds);
end

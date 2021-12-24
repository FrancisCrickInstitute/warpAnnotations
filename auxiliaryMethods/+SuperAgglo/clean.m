function agglos = clean(agglos, check)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~exist('check', 'var') || isempty(check)
        check = true;
    end
    
    for curIdx = 1:numel(agglos)
        agglos(curIdx) = core(agglos(curIdx));
    end
    
    % Perform check, if desired
    if check; SuperAgglo.check(agglos); end
end

function agglo = core(agglo)
    agglo.nodes = double(agglo.nodes);
    agglo.edges = double(agglo.edges);
    
    % Remove self-edges
    agglo.edges(agglo.edges(:, 1) ...
        == agglo.edges(:, 2), :) = [];
    
    % Sort edges (make them undirected)
    agglo.edges = sort(agglo.edges, 2);
    
    % Get rid of duplicate edges
    agglo.edges = unique(agglo.edges, 'rows');
end

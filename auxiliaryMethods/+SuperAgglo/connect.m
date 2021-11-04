function agglos = connect(agglos)
    % agglos = connect(agglos)
    %   Makes sure that super-agglomerates are connected by introducing
    %   random edges between the different connected component.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    agglos = arrayfun(@forAgglo, agglos);
end

function agglo = forAgglo(agglo)
    % Make sure edges are undirected
    agglo.edges = sort(agglo.edges, 2);
    
    adjMat = sparse( ...
        agglo.edges(:, 2), agglo.edges(:, 1), ...
        true, size(agglo.nodes, 1), size(agglo.nodes, 1));
   [compCount, compIds] = graphconncomp(adjMat, 'Directed', false);
   
    % Only one component? We're done!
    if compCount <= 1; return; end
    
    % Find and add new edges
   [~, nodeIds] = unique(compIds, 'stable');
    newEdges = nan(numel(nodeIds) - 1, 2);
    newEdges(:, 1) = nodeIds(1);
    newEdges(:, 2) = nodeIds(2:end);
    agglo.edges = [agglo.edges; newEdges];
end

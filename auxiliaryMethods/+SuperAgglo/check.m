function check(agglos)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % Check segment equivalence classes
    segEq = Agglo.fromSuperAgglo(agglos, true);
    Agglo.check(segEq);
    
    % Check super-agglomerates
    for curIdx = 1:numel(agglos)
        core(agglos(curIdx));
    end
end

function core(agglo)
    assert(isa(agglo.nodes, 'double'));
    assert(isa(agglo.edges, 'double'));
    
    % Check nodes
    assert(not(isempty(agglo.nodes)));
    assert(all(all(agglo.nodes(:, 1:3) > 0)));
    assert(all(isnan(agglo.nodes(:, 4)) | agglo.nodes(:, 4) >= 1));
    
    % Check edges
    assert(all(agglo.edges(:) >= 1 & ...
        agglo.edges(:) <= size(agglo.nodes, 1)));
    assert(all(agglo.edges(:, 2) > agglo.edges(:, 1)));
    
    % Check connectedness
    adjMat = sparse( ...
        agglo.edges(:, 2), agglo.edges(:, 1), ...
        1, size(agglo.nodes, 1), size(agglo.nodes, 1));
    adjMat(1, 1) = 1;
    
    compCount = graphconncomp(adjMat, 'Directed', false);
    assert(compCount == 1);
end

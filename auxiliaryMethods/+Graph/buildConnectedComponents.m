function [segLabels, agglos] = ...
        buildConnectedComponents(maxSegId, edges)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % sanity check
    assert(all(edges(:, 1) < edges(:, 2)));
    
    maxSegId = double(maxSegId);
    edges = double(edges);
    
    % calculate connected components
    adjMat = sparse(edges(:, 2), edges(:, 1), 1, maxSegId, maxSegId);
    [~, segLabels] = graphconncomp(adjMat, 'Directed', false);
    clear adjMat;
    
    % ignore segments, which were not in edges
    zeroMask = true(1, maxSegId);
    zeroMask(edges) = false;
    
    segLabels(zeroMask) = 0;
    clear zeroMask;
    
    % continuous renumbering
    [~, ~, segLabels] = unique(segLabels);
    
    % build agglomerates, if desired
    if nargout >= 2
        agglos = accumarray( ...
            segLabels, 1:maxSegId, [], @(segIds) {segIds(:)});
        agglos = agglos(2:end);
    end
    
    % fix labels
    segLabels = segLabels - 1;
end

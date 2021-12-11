function surfaceAreas = calculateSurfaceArea(edges, borderAreas, agglos)
    % surfaceAreas = calculateSurfaceArea(edges, borderAreas, agglos)
    %   Calculates the surface area for a set of agglomerates.
    %
    % Inputs
    % * edges
    %     Nx2 numeric matrix with (undirected) edges
    % * borderAreas
    %     Numeric vector with the surface area for each edge
    % * agglos
    %     Integer matrix describing a segment equivalence class, or a cell
    %     matrix of segment equivalence classes (as above).
    %
    % Outputs
    % * surfaceAreas
    %     Matrix with surface area for each agglomerate. The shape is the
    %     same as that out `agglos` (if it is a cell array).
    % 
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~iscell(agglos); agglos = {agglos}; end
    surfaceAreas = nan(size(agglos));
    
    for curIdx = 1:numel(agglos)
        curMask = ismember(edges, agglos{curIdx});
        curMask = xor(curMask(:, 1), curMask(:, 2));
        surfaceAreas(curIdx) = sum(borderAreas(curMask));
    end
end
function pathLengths = pathLength(agglos, voxelSize)
    % pathLengths = pathLength(agglos, voxelSize)
    %   Calculates the path length of super-agglomerates. To this end, the
    %   edge lengths of the minimum spanning tree trough the edges of the
    %   super-agglomerate are added up.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    if ~exist('voxelSize', 'var') || isempty(voxelSize)
        voxelSize = [1, 1, 1];
    end
    
    assert(isequal(size(voxelSize), [1, 3]));
    pathLengths = arrayfun(@(a) forAgglo(a, voxelSize), agglos);
end

function pathLength = forAgglo(agglo, voxelSize)
    pathLength = ...
        agglo.nodes(agglo.edges(:, 1), 1:3) ...
      - agglo.nodes(agglo.edges(:, 2), 1:3);
    pathLength = voxelSize .* pathLength;
    pathLength = pathLength .* pathLength;
    pathLength = sqrt(sum(pathLength, 2));
    
    pathLength = graph( ...
        agglo.edges(:, 1), agglo.edges(:, 2), ...
        pathLength, size(agglo.nodes, 1));
    pathLength = minspantree(pathLength);
    pathLength = sum(pathLength.Edges.Weight);
end

function agglos = toMST(agglos, voxelSize)
    % agglos = toMST(agglos, voxelSize)
    %   Replaces the edges of each super-agglomerate with the these of the
    %   corresponding minimal spanning tree.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    if ~exist('voxelSize', 'var') || isempty(voxelSize)
        voxelSize = [1, 1, 1];
    end
    
    agglos = arrayfun(@(a) forAgglo(a, voxelSize), agglos);
end

function agglo = forAgglo(agglo, voxelSize)
    edges = agglo.nodes(:, 1:3) .* voxelSize;
    
    % NOTE(amotta): `squareform(pdist(..))` wrongly produces an empty
    % matrix in case of a single node. Let's fix this by always having at
    % least one node. This also produces the right result when there are no
    % nodes at all.
    edges = squareform(pdist(edges));
    edges(1, 1) = 0;
    
    edges = graphminspantree(sparse(edges));
    edges = Graph.adj2Edges(edges);
    
    agglo.edges = double(edges);
end

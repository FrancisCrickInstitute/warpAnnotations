function graph = reduce(graph)
    % graph = reduce(graph)
    %   Reduces the multigraph to a "simple" graph, where each edge occurs
    %   at most once. For edges with multiplicity above one only the most
    %   probable edge is kept.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    graph = sortrows(graph, {'edges', 'prob'}, {'ascend', 'descend'});
    [~, uniRowIds] = unique(graph.edges, 'rows');
    graph = graph(uniRowIds, :);
end

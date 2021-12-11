function graph = addNeighbours(graph)
    % graph = addNeighbours(graph)
    %   This function takes a graph structure (with the `edges` and `prob`
    %   fields) and adds the `neighbours` and `neighProb` fields.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
   [graph.neighbours, neighRows] = Graph.edges2Neighbors(graph.edges);
    graph.neighProb = cell(size(graph.neighbours));
    
    for curIdx = 1:numel(neighRows)
        graph.neighProb{curIdx} = graph.prob(neighRows{curIdx});
    end
end
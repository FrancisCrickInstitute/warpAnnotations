function graph = load(rootDir)
    % graph = load(rootDir)
    %   Loads the global graph structure and converts it into
    %   a table for convenience.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    graphFile = fullfile(rootDir, 'graph.mat');
    graph = load(graphFile, 'edges', 'prob', 'borderIdx');
    
    % NOTE(amotta): Use border idx zero instead of nan
    graph.borderIdx(isnan(graph.borderIdx)) = 0;
    
    % make table (more convenient)
    graph = struct2table(graph);
end

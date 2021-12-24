function uniSegIds = getUniqueSegIds(param)
    % uniSegIds = getUniqueSegIds(param)
    %   Returns a list of all (unique) global segment IDs
    %   encountered in the data set. The segment IDs are
    %   in ascending order.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    rootDir = param.saveFolder;
    graph = load([rootDir, 'graph.mat'], 'edges');
    
    % remove duplicates (and sort)
    uniSegIds = unique(graph.edges(:));
end
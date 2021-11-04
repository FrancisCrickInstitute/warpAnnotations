function segIds = getSegmentIdsOfSkel(param, skel)
    % GETSEGMENTIDSOFSKEL
    %   Queries the global segment IDs for each node in
    %   the given skeleton object.
    %
    % param
    %   Dataset-specific parameter structure produced by
    %   `run configuration.m`
    %
    % skel
    %   Skeleton object as produced by skeleton(nmlFile)
    %
    % segIds
    %   Nx1 cell array, where N is the number of trees in
    %   skel. Each cell containts the global segment IDs
    %   for each node of the corresponding tree.
    %
    %   See getSegmentIdsOfNodes for more detauls about
    %   the returned segment IDs.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % collect all nodes
    nodes = skel.nodes;
    nodes = cellfun( ...
        @(coords) {coords(:, 1:3)}, nodes);
    nodes = vertcat(nodes{:});
    
    % query segment IDs
    segIds = Skeleton.getSegmentIdsOfNodes(param, nodes);
    
    % split up results
    segIds = mat2cell(segIds, skel.numNodes(), 1);
    
end
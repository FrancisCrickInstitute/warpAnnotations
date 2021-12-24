function agglos = buildAgglomerates(param, nml)
    % agglos = buildAgglomerates(param, nodes)
    %   Builds agglomerates from an NML file. Each node corresponds to the
    %   segment it was placed in. Trees correspond to agglomerates.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    nodes = NML.buildNodeTable(nml);

    % get rid of invalid nodes
    nodes.coord = nodes.coord + 1;
    nodes(any(bsxfun(@lt, nodes.coord, param.bbox(:, 1)'), 2), :) = [];
    nodes(any(bsxfun(@gt, nodes.coord, param.bbox(:, 2)'), 2), :) = [];

    % look up segment IDs
    nodes.segId = Seg.Global.getSegIds(param, nodes.coord);
    
    % remove nodes on borders
    nodes(not(nodes.segId), :) = [];
    
    % group per tree
    [~, ~, nodes.treeIdRel] = unique(nodes.treeId);
    
    aggloFunc = @(segIds) {unique(segIds(:))};
    agglos = accumarray(nodes.treeIdRel, nodes.segId, [], aggloFunc);
end

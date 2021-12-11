function [edges, classes] = getEdgesFromDense(param, nmlFile)
    % [edges, classes] = getEdgesFromDense(param, nmlFile)
    %   This function extracts a list of all edges and their
    %   classification (+1 for connected, -1 for disconnected)
    %   from an NML file.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % parse NML file
    nml = slurpNml(nmlFile);
    
    % build tables
    nodes = NML.buildNodeTable(nml);
    nodes.coord = nodes.coord + 1;
    
    % drop nodes outside bounding box
    box = param.bbox;
    boxMask = all( ...
          bsxfun(@ge, nodes.coord, box(:, 1)') ...
        & bsxfun(@le, nodes.coord, box(:, 2)'), 2);
    nodes = nodes(boxMask, :);
    
    % look up segment IDs
    nodes.segId = Util.getSegIds( ...
        param, nodes.coord);
    
    % build equivalence classes
    eqClasses = buildEqClasses(nodes);
    lut = buildEqClassLUT(param, eqClasses);
    
    % find edges and their classes
    rootDir = param.saveFolder;
    load([rootDir, 'graph.mat'], 'edges');
    
    % make edges unique
    edges = unique(edges, 'rows');
    
    % only keep edges with labelled end
    keepMask = all(logical(lut(edges)), 2);
    
    edges = edges(keepMask, :);
    edgeCount = size(edges, 1);
    
    % find classes
    matchMask = diff(lut(edges), 1, 2) == 0;
    
    % build output
    classes = ones(edgeCount, 1);
    classes(~matchMask) = -1;
end

function eqClasses = buildEqClasses(nodes)
    treeIds = nodes.treeId;
    uniTreeIds = unique(treeIds);
    
    doTree = @(treeId) unique(nodes.segId( ...
        nodes.segId  ~= 0 ...
      & nodes.treeId == treeId));
    eqClasses = arrayfun( ...
        doTree, uniTreeIds, ...
        'UniformOutput', false);
end

function lut = buildEqClassLUT(param, eqClasses)
    maxSegId = Seg.Global.getMaxSegId(param);
    eqClassCount = numel(eqClasses);
    
    % prepare output
    lut = zeros(maxSegId, 1);
    resetMask = false(maxSegId, 1);
    
    for curIdx = 1:eqClassCount
        curSegIds = eqClasses{curIdx};
        curClassPrev = lut(curSegIds);
        
        % update reset mask
        curResetMask = logical(curClassPrev);
        resetMask(curSegIds(curResetMask)) = true;
        
        % write look-up table
        lut(curSegIds(~curResetMask)) = curIdx;
    end
    
    % apply reset mask
    lut(resetMask) = 0;
end

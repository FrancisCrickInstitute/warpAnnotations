function skel = fromAgglo( ...
        graph, com, agglos, varargin)
    % FROMAGGLO
    %   Build nice skeletons from agglomerates.
    %
    % Inputs
    %   graph:
    %     Struct with 'edges' property (N x 2). The 'prob'
    %     property (N x 1) is only required if 'minEdgeProb'
    %     is set.
    %   com:
    %     M x 3 matrix where the entries in row j are the
    %     coordinates of segment j's center of mass
    %   agglos:
    %     Cell array. Each cell contains a list of
    %     segment ids.
    %
    % Key-Value Pairs
    %
    %   edgeIds:
    %     Optional. If set, only the specified rows of the
    %     `graph` input argument are kept for the generation
    %     of trees. Default: Keep all edges.
    %
    %   minEdgeProb:
    %     Optional. If set, the produced skeleton will only
    %     contain edges with a probability above the given
    %     threshold. Default: Keep all edges.
    %
    %   treeColors:
    %     Optional. If set, the agglomerates will be assigned
    %     the given colors. The rows of `treeColors` correspond
    %     to different trees. Each row must contain RGBA values.
    %     Default: All trees are red.
    %
    %   treeNames:
    %     Optional. Cell array with name for each tree.
    %     Default: Auto-generate names with `treePrefix`.
    %
    %   treePrefix
    %     Optional. Prefix for auto-generation of tree names.
    %     Default: 'Agglomerate '
    %
    % Written by
    %   Manuel Berning <manuel.berning@brain.mpg.de>
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % parse options
    opts = parseOptions(varargin);
    
    % filter edges by IDs
    if ~isempty(opts.edgeIds)
        graph.edges = graph.edges(opts.edgeIds, :);
        graph.prob = graph.prob(opts.edgeIds);
    end
    
    % filter edges by probabilities
    if ~isempty(opts.minEdgeProb)
        keepMask = (graph.prob >= minEdgeProb);
        graph.edges = graph.edges(keepMask, :);
        graph.prob = graph.prob(keepMask);
        clear keepMask;
    end
    
    % skip empty agglomerates
    agglos = agglos(cellfun(@(a) ~isempty(a), agglos));
    aggloCount = numel(agglos);
    
    % generate names, if necessary
    if isempty(opts.treeNames) ...
            || numel(opts.treeNames) ~= aggloCount
        % how many digits do we need?
        digitCount = floor(log(aggloCount) / log(10)) + 1;
        numFormat = ['%0', num2str(digitCount), 'd'];
        
        % generate names
        treeNames = arrayfun(@(i) ...
            [opts.treePrefix, num2str(i, numFormat)], ...
            1:aggloCount, 'UniformOutput', false);
        clear digiCount numFormat 
    else
        treeNames = opts.treeNames;
    end
    
    % generate colors, if needed
    if ~ismatrix(opts.treeColors) ...
            || any(size(opts.treeColors) ~= [aggloCount, 4])
        treeColors = repmat([1, 0, 0, 1], aggloCount, 1);
    else
        treeColors = opts.treeColors;
    end
    
    %% prepare skeleton
    skel = skeleton();
    
    for aggloIdx = 1:aggloCount
        treeName = treeNames{aggloIdx};
        treeColor = treeColors(aggloIdx, :);
        
        % build nodes
        aggloSegIds = agglos{aggloIdx};
        treeNodes = com(aggloSegIds, :);
        
        % build edges
        [~, treeEdges] = ismember(graph.edges, aggloSegIds);
        treeEdges(not(all(treeEdges, 2)), :) = [];

        % build tree
        skel = addTree( ...
            skel, treeName, ...
            treeNodes, treeEdges, treeColor);
    end
end

function opts = parseOptions(keyVals)
    opts = struct;
    opts.edgeIds = [];
    opts.minEdgeProb = [];
    opts.treeNames = {};
    opts.treeColors = [];
    opts.treePrefix = 'Agglomerate ';
    
    % override default values
    opts = Util.modifyStruct(opts, keyVals{:});
end

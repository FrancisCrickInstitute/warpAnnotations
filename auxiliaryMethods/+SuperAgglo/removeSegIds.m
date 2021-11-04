function agglos = removeSegIds(param, agglos, segIds)
    % agglos = removeSegIds(param, agglos, segIds, varargin)
    %   Removes a set of segments from super-agglomerates. If the node
    %   removal causes a super-agglomerate to fall into multiple connected
    %   components, the splits are heal by adding the minimal set (both in
    %   terms of number and total path length) of edges.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    voxelSize = param.raw.voxelSize;
    maxSegId = Seg.Global.getMaxSegId(param);
    keepLUT = ~Agglo.buildLUT(maxSegId + 1, {segIds});
    
    for curIdx = 1:numel(agglos)
        curAgglo = agglos(curIdx);
        
        curNodeIds = curAgglo.nodes(:, 4);
        curNodeIds(isnan(curNodeIds)) = maxSegId + 1;
        curNodeIds = keepLUT(curNodeIds);
        
        if all(curNodeIds); continue; end
        curNodeIds = find(curNodeIds);
        
        % Remove masked nodes and their edges
        curAgglo.nodes = curAgglo.nodes(curNodeIds, :);
        curNodeCount = size(curAgglo.nodes, 1);
        
       [~, curAgglo.edges] = ismember(curAgglo.edges, curNodeIds);
        curAgglo.edges(~all(curAgglo.edges, 2), :) = [];
        curAgglo = SuperAgglo.clean(curAgglo, false);
        
        % Heal splits
        curGraph = sparse( ...
            curAgglo.edges(:, 2), curAgglo.edges(:, 1), ...
            true, curNodeCount, curNodeCount);
       [curCompCount, curCompIds] = ...
            graphconncomp(curGraph, 'Directed', false);
        
        % There's a single component? We're done!
        if curCompCount <= 1; continue; end
        
        % Build connecting edges
        curCompIds = accumarray( ...
            curCompIds(:), (1:curNodeCount)', [], @(ids) {ids});
        
        % For each pair of components, find the shortest edge which could
        % be used to join them. These are our candidate edges.
        curEdgeCands = zeros(0, 5);
        for curIdxA = 1:(curCompCount - 1)
            curNodeIdsA = curCompIds{curIdxA};
            curNodesA = voxelSize .* curAgglo.nodes(curNodeIdsA, 1:3);
            
            for curIdxB = (curIdxA + 1):curCompCount
                curNodeIdsB = curCompIds{curIdxB};
                curNodesB = voxelSize .* curAgglo.nodes(curNodeIdsB, 1:3);
                
                % Find shortest connection
                curDists = pdist2( ...
                    curNodesA, curNodesB, 'squaredeuclidean');
                
               [curMinDist, curMinIdx] = min(curDists(:));
                curMinDist = sqrt(curMinDist); 
               
                curEdge = zeros(1, 2);
               [curEdge(1), curEdge(2)] = ...
                    ind2sub(size(curDists), curMinIdx);
                curEdge(1) = curNodeIdsA(curEdge(1));
                curEdge(2) = curNodeIdsB(curEdge(2));
                
                % Add edge to list
                curEdgeCands(end + 1, :) = [ ...
                    curIdxA, curIdxB, curMinDist, curEdge]; %#ok
            end
        end
        
        % Select the minimal set from the candidate edges to join the
        % different connected components.
        curGraph = sparse( ...
            curEdgeCands(:, 2), curEdgeCands(:, 1), ...
            curEdgeCands(:, 3), curCompCount, curCompCount);
        curGraph = graphminspantree(curGraph);
        
        curEdges = zeros(curCompCount - 1, 2);
       [curEdges(:, 2), curEdges(:, 1)] = find(curGraph);
       
       [~, curEdges] = ismember( ...
            curEdges, curEdgeCands(:, 1:2), 'rows');
        curEdges = curEdgeCands(curEdges, 4:5);
        
        % Patch in edges
        curAgglo.edges = [curAgglo.edges; curEdges];
        agglos(curIdx) = curAgglo;
    end
end

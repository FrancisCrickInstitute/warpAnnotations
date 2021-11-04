function [nodeLabels, nodeDists, edges] = ...
        buildDendrogram(adjMat, refId, minLen)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    assert(graphisspantree(adjMat));
    nodeCount = size(adjMat, 1);
    
    nodeDists = graphshortestpath( ...
        adjMat, refId, 'Directed', false);
    nodeDists = reshape(nodeDists, [], 1);
    
    edges = nan(nnz(adjMat), 2);
   [edges(:, 2), edges(:, 1), edgeLens] = find(adjMat);
    clear adjMat;
    
    % find branch point candidates and leafs
    nodeDegrees = accumarray( ...
        edges(:), 1, [nodeCount, 1]);
    tipNodeIds = find(nodeDegrees == 1);
    
    % orient edges towards reference node
    flipMask = ...
        nodeDists(edges(:, 2)) ...
      > nodeDists(edges(:, 1));
    edges(flipMask, :) = ...
        fliplr(edges(flipMask, :));
    clear flipMask;
    
    % determine edge towards predecessor for each node
   [~, nodePredLUT] = ismember(1:nodeCount, edges(:, 1));
   
    %% calculate distance to farthest tip for each edge
    edgeToTipDists = zeros(size(edges, 1), 1);
    for curSeedId = reshape(tipNodeIds, 1, [])
        curNodeId = curSeedId;
        curDistToTip = 0;

        while curNodeId ~= refId
            curPredEdgeId = nodePredLUT(curNodeId);
            curDistToTip = curDistToTip + edgeLens(curPredEdgeId);
            
            if curDistToTip < ...
                    edgeToTipDists(curPredEdgeId)
                % We're at a branch point that has already been visited
                % starting from a tip node which is even further away.
                % Leave precedence to other path...
                break;
            end
            
            edgeToTipDists(curPredEdgeId) = curDistToTip;
            curNodeId = edges(curPredEdgeId, 2);
        end
    end
    
    %% group / label nodes
    nodeSuccLUT = accumarray( ...
        edges(:, 2), 1:size(edges, 1), ...
       [nodeCount, 1], @(edgeIds) {edgeIds(:)});

    maxLabelId = 1;
    nodeStack = refId;
    
    nodeLabels = zeros(nodeCount, 1);
    nodeLabels(refId) = maxLabelId;
    while ~isempty(nodeStack)
        curNodeId = nodeStack(end);
        nodeStack(end) = [];

        curLabelId = nodeLabels(curNodeId);
        curSuccEdgeId = nodeSuccLUT{curNodeId};

        curSuccNodeIds = edges(curSuccEdgeId, 1);
        nodeStack = cat(1, nodeStack(:), curSuccNodeIds);

        curSuccDists = edgeToTipDists(curSuccEdgeId) > minLen;
        curSuccDiffBranch = curSuccDists & sum(curSuccDists) > 1;

        curSuccLabels = zeros(size(curSuccNodeIds));
        curSuccLabels(:) = curLabelId;
        curSuccLabels(curSuccDiffBranch) = ...
            maxLabelId + (1:sum(curSuccDiffBranch));

        nodeLabels(curSuccNodeIds) = curSuccLabels;
        maxLabelId = maxLabelId + sum(curSuccDiffBranch);
    end
    
    %% sanity checks
    assert(all(nodeLabels));
end
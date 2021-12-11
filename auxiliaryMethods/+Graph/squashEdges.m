function [newEdges, newWeights] = ...
        squashEdges(edges, weights, func)
    % SQUASHEDGES
    %   Scan the list of edges in the graph for entries
    %   that occur more than once. The weights of edges
    %   with multiplicity higher than one are squashed
    %   using a user-define function.
    %
    % Inputs
    %   edges: Nx2
    %     Edge matrix with vertex indices
    %
    %   weights: Nx1 (Optional)
    %     Edge weights
    %     Default: ones(N, 1)
    %
    %   func: function handle (optional)
    %     Function to squash weights
    %     Default: @max
    %
    % Outputs
    %   newEdges: Mx2
    %     Edge matrix without repetitions
    %
    %   newWeights: Mx1
    %     Weights for edges in newEdges
    %
    % Invariants
    %   M <= N
    % 
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    edgeCount = size(edges, 1);
    
    if exist('weights', 'var')
        assert(size(weights, 1) == edgeCount);
        assert(size(weights, 2) == 1);
    else
        weights = ones(edgeCount, 1);
    end
    
    if ~exist('func', 'var')
        func = @max;
    end
    
    [newEdges, ~, newEdgeRows] = ...
        unique(edges, 'rows');
    newWeights = accumarray( ...
        newEdgeRows, weights, [], func);
end
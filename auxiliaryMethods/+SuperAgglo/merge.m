function out = merge(left, right)
    % out = merge(left, right)
    %   Merges the `right` super-agglomerate into the `left` super-
    %   agglomerate based on nodes with common segment IDs.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
   [~, rightToLeft] = ismember( ...
        right.nodes(:, 4), left.nodes(:, 4));
    rightToLeft = reshape(rightToLeft, 1, []);
    
    % nodes to be added to `left`
    newNodes = right.nodes(~rightToLeft, :);
    
    % edges to be added to `left`
    rightToLeft(~rightToLeft) = ...
        size(left.nodes, 1) + (1:size(newNodes, 1));
    newEdges = rightToLeft(right.edges);
    
    % build output
    out = struct;
    out.nodes = cat(1, left.nodes, newNodes);
    out.edges = cat(1, left.edges, newEdges);
    
    % let's be super pedantic about edges
    out.edges = sort(out.edges, 2);
    out.edges = unique(out.edges, 'rows');
end

function edges = getMST(com,thr)
% This function calculates the minimum spanning tree (MST) from a set of
% coordinates and optionally applies a distance threshold
% INPUT
% com       m-by-3 list of coordinates, e.g. centers of mass
% thr       distance threshold (unit same as com) above which the MST edges
%           are ignored. Useful for very big structures
%
% OUTPUT
% edges     n-by-2 list of edges
%
% by Marcel Beining <marcel.beining@brain.mpg.de>

if ~exist('thr','var')
    thr = [];
end
if size(com,1) < 2
    edges = zeros(0, 2);
else
    % Minimal spanning tree
    adj = pdist(com);
    
    if isempty(thr)
        % NOTE(amotta): Prim is faster than `Kruskal` and
        % is guaranteed to work when using the unmodified
        % output of `pdist`.
        method = 'Prim';
    else
        adj(adj > thr) = 0;
        method = 'Kruskal';
    end
    
    adj = sparse(squareform(adj));
    tree = graphminspantree(adj, 'Method', method);
    
    edges = zeros(nnz(tree), 2);
   [edges(:, 2), edges(:, 1)] = find(tree);
end
end

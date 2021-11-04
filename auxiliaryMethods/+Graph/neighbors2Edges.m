function edges = neighbors2Edges( neighbors, mode )
%NEIGHBORS2EDGES Create edge list from neighbor list.
% INPUT neighbors: Cell array where i-th cell contains the neighbor nodes
%                  of the node with ID/index i. Cells can be empty.
%       mode: (Optional). Specify whether edges represent 'directed' or
%             'undirected' edges. In the directed case the edge orientation
%             is defined from the first to the second node ID in edges.
%             (Default: 'undirected');
% OUTPUT edges: [Nx2] integer array. Each row defines an edge between the
%               corresponding nodes. (The entries in edges can be indices
%               of nodes in a skel or IDs of nodes).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>


% % this seems to be slower than the for loop
% edges = zeros(sum(cellfun(@length,neighbors)),2,'uint32');
% l = cellfun(@length, neighbors);
% edges(:,1) = repelem(1:length(neighbors), l)';
% edges(:,2) = cell2mat(cellfun(@(x)x(:), neighbors, 'uni', 0));

edges = zeros(sum(cellfun(@length,neighbors)),2,'uint32');
count = 1;
for i = 1:length(neighbors)
    l = length(neighbors{i});
    if l > 0
        edges(count:count + l - 1,1) = i;
        edges(count:count + l - 1,2) = neighbors{i}';
        count = count + l;
    end
end

if ~exist('mode','var') || strcmp(mode,'undirected')
    edges = sort(edges,2);
    edges = unique(edges,'rows');
end

end

function [ neighbors, neighborsIdx ] = edges2Neighbors_slow( edges, mode )
%EDGES2NEIGHBORS Calculate a cell array of neighbor IDs of each node.
% INPUT edges: [Nx2] integer array. Each row defines an edge between the
%              corresponding nodes. (The entries in edges can be indices of
%              nodes in a skel or IDs of nodes).
%       mode: (Optional). Specify whether edges represent 'directed' or
%             'undirected' edges. In the directed case the edge orientation
%             is defined from the first to the second node ID in edges.
%             (Default: 'undirected');
% OUTPUT neighbors: Cell array of length max(edges(:)). The i-th cell
%           contains neighboring nodes of the node with ID i.
%        neighborsIdx: Cell array of length max(edges(:)). The i-th cell
%           contains the id of the edge between the node with ID i
%           and its neighbor in neighbors.
%
% NOTE If neighborsIdx output is requested then then the cells in neighbors
%      can contain the same id multiple times for different edges.
% NOTE If only neighbors is requested then a unique is run on each cell.
% NOTE This function produces the neighbor list with different ordering
%      for each neighbor than the edges2Neighbors function.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% 28 Oct 2015: Uniquify neighbor list
%              (Thomas Kipf <thomas.kipf@brain.mpg.de>)

warning('DEPRECATED: Use edges2Neighbors instead.');

if ~exist('mode','var') || isempty(mode)
    mode = 'undirected';
end

neighbors = cell(max(edges(:)),1);
if nargout == 2
    neighborsIdx = cell(max(edges(:)),1);
end
for i = 1:size(edges,1)
    n1 = edges(i,1);
    n2 = edges(i,2);
    neighbors{n1} = [neighbors{n1}, n2];
    if strcmp(mode,'undirected')
        neighbors{n2} = [neighbors{n2}, n1];
    end
    if nargout == 2
        neighborsIdx{n1} = [neighborsIdx{n1}, i];
        if strcmp(mode,'undirected')
            neighborsIdx{n2} = [neighborsIdx{n2}, i];
        end
    end
end

%only uniquify neighbors list if idx are not kept
if nargout == 1
    idx = cellfun(@isempty,neighbors);
    neighbors(~idx) = cellfun(@unique,neighbors(~idx),'UniformOutput',false);
end

end

function edgesIdx = findEdges( edges, ids, mode )
%FINDEDGES Find the index of an edge.
% INPUT edges: [Nx2] array of integer specifying the edges between node
%           ids.
%       ids: [Nx2] array of integer specifying the edges to search for.
%       mode: (Optional) String specifying the search mode. Options are
%           'directed': Edges in ids are oriented from first to second
%               columnd.
%           'undirected': (Default) Edges in ids are not oriented.
% OUTPUT edgesIdx: [Nx1] cell array containing the row index of all matches
%           in edges for the corresponding row in ids.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('mode','var') || isempty(mode)
    mode = 'undirected';
end

edgesIdx = cell(size(ids,1),1);
for i = 1:size(ids,1)
    switch mode
        case 'directed'
            idx = edges(:,1) ==  ids(i,1) & edges(:,2) ==  ids(i,2);
            edgesIdx{i} = find(idx);
        case 'undirected'
            idx1 = any(edges == ids(i,1),2);
            idx21 = any(edges(idx1,:) == ids(i,2),2);
            idx1(idx1) = idx21;
            edgesIdx{i} = find(idx1);
        otherwise
            error('Unknown search mode %s.',mode);
    end
end


end


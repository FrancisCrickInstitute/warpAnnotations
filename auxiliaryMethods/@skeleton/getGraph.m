function G = getGraph( skel, treeIdx, edgesOnly )
%GETGRAPH Create a matlab graph object from the skeleton tree.
% INPUT treeIdx: int
%           Linear index of the tree of interest.
%       edgesOnly: (Optional) flag
%           Flag to output the graph with edges only.
%           (Default: true)
% OUTPUT G: graph
%           Matlab graph object with the nodes and edges of the
%           corresponding tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('edgesOnly', 'var') || isempty(edgesOnly)
    edgesOnly = true;
end

e = skel.edges{treeIdx};

if edgesOnly
    G = graph(e(:,1), e(:,2));
else
    nodesTable = table(skel.nodes{treeIdx}(:, 1:3), ...
        'VariableNames', {'coords'});
    G = graph(e(:,1), e(:,2), [], nodesTable);
end


end


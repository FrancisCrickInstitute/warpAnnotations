function nodes = reachableNodes(obj, tree_index, nodes, steps, mode)
% Calculate the nodes that can be reached in a fixed number of
% steps from a set of starting nodes.
% INPUT tree_index: int
%           The linear index of the tree of interest.
%       nodes: [Nx1] logical or [Nx1] int array
%           Logical or linear indices of the nodes in tree tree_index
%           to start from.
%       steps: int
%           Number of steps to make from each starting node.
%       mode: string
%           Specify search mode
%           'exact': Calculate all nodes which can be reached
%               in exactly the number of specified steps.
%           'exact_excl': As exact but excluding the initial
%               nodes.
%           'up_to': Calculate all nodes which can be reached
%               in up in at most the number of specified steps.
%           'up_to_excl': Same as 'up_to' excluding the input
%               nodes. This can be used to calculate the next
%               step neighbors of a node.
% OUTPUT nodes: [Nx1] logical
%           The reachable nodes as logical indices of the nodes in the
%           specified tree.

if isrow(nodes)
    nodes = nodes';
end

%convert to logical indices if required
if ~islogical(nodes)
    tmp = false(size(obj.nodes{tree_index},1),1);
    tmp(nodes) = true;
    nodes = tmp;
end

am = obj.createAdjacencyMatrix(tree_index);
switch mode
    case 'exact'
        nodes = logical(am^steps*nodes);
    case 'exact_excl'
        nodes = logical(am^steps*nodes) & (~nodes);
    case 'up_to'
        am = am + speye(size(am));
        nodes = logical(am^steps*nodes);
    case 'up_to_excl'
        am = am + speye(size(am));
        nodes = logical(am^steps*nodes) & ~nodes;
    otherwise
        error('Unknown mode ''%s'' specified',mode);
end
end
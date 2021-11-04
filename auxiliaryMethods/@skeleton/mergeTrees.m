function skel = mergeTrees( skel, varargin )
%MERGETREES Merge two trees of a skeleton.
% USAGE
%   skel.mergeTrees(id1, id2)
%       Connect the nodes with id1 and id2 and merge the corresponding
%       trees.
%   skel.mergeTrees(tree1, node1, tree2, node2)
%       Merge the trees with linear indices tree1 and tree2 by connecting
%       the nodes with linear indices node1 and node2. The node indices are
%       linear indices w.r.t. to the corresponding tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%add all nodes of second tree to first tree
if length(varargin) == 4
    [tree1, node1, tree2, node2] = varargin{:};
    numNodes1 = size(skel.nodes{tree1}, 1);
    skel.nodes{tree1} = [skel.nodes{tree1}; skel.nodes{tree2}];
    skel.nodesAsStruct{tree1} = [skel.nodesAsStruct{tree1}, ...
        skel.nodesAsStruct{tree2}];
    skel.nodesNumDataAll{tree1} = [skel.nodesNumDataAll{tree1}; ...
        skel.nodesNumDataAll{tree2}];
    skel.edges{tree1} = [skel.edges{tree1}; skel.edges{tree2} + numNodes1; ...
        node1, node2 + numNodes1];
    skel = skel.deleteTrees(tree2);
elseif length(varargin) == 2
    [tree1, node1] = skel.getNodesWithIDs(varargin{1});
    [tree2, node2] = skel.getNodesWithIDs(varargin{2});
    if tree1 == tree2
        error('Both ids belong to the same node.');
    end
    skel = skel.mergeTrees(tree1, node1, tree2, node2);
else
    error('Wrong number of input parameters specified.');
end



end


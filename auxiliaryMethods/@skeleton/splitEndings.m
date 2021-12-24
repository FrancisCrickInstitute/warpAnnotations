function [skelNew, skelEnd] = splitEndings(skel, comment, steps, mode, closeGap)
% Description:
%   split the tree at ending nodes with comment upto steps away from that node 
%   and return all such split ending groups in skelEnd

% Input:
%   comment: 'end'
%   steps: 3, away from end node
%   mode: string, same as reachableNodes function
%   closeGap: Boolean, if set to true, keeps one node common in skelNew and skelEnd
%
% Output:
%   skel: original skel but with end nodes removed at n steps
%   skelEnd: skel with just the nodes split per ending as trees
%
% Author:
% Sahil Loomba <sahil.loomba@brain.mpg.de>

nodesWithComment = skel.getNodesWithComment(comment);
nodesReachable = cell(skel.numTrees,1);
nodesReachableToDel = cell(skel.numTrees,1);
for tree_index = 1:skel.numTrees
    nodes = nodesWithComment{tree_index};
    if ~isempty(nodes)
        for i=1:size(nodes,1)
            nodesReachable{tree_index}{i} = reachableNodes(skel, tree_index, nodes(i), steps, mode);
            if closeGap
                nodesReachableToDel{tree_index}{i} = reachableNodes(skel, tree_index, nodes(i), steps-1, mode);
            else
                nodesReachableToDel{tree_index}{i} = nodesReachable{tree_index}{i};
        end
    end
end

skelNew = skel;
skelEnd = skeleton();
skelEnd = skelEnd.setParams(skel.parameters.experiment.name, skel.scale,...
                [str2num(skel.parameters.offset.x), str2num(skel.parameters.offset.y),...
                str2num(skel.parameters.offset.z)]);

for tree_index = 1:skel.numTrees
    nodesR = nodesReachable{tree_index};
    nodesRD = nodesReachableToDel{tree_index};
    toDel = [];
    if ~isempty(nodesR)
        for i=1:numel(nodesR)
            skelEnd = skelEnd.addTree('',skel.nodes{tree_index}(nodesR{i},:));
            toDel = vertcat(toDel,find(nodesRD{i}));
        end
    skelNew = skelNew.deleteNodes(tree_index,toDel);
    end
end





end

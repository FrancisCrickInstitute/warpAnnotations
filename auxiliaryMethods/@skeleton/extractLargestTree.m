function [obj,treeIdx] = extractLargestTree(obj)
% find the tree with largest number of nodes in the skeleton
% input: obj: skeleton clas object
% output: 
%       obj: skeleton class object with only the largest tree
%       treeIdx: index of the largest tree in input obj   
% Written by:
%     Sahil Loomba <sahil.loomba@brain.mpg.de>

[~,treeIdx] = max(cellfun(@(x) size(x,1),obj.nodes));

treeIndicesToDel = true(obj.numTrees,1);
treeIndicesToDel(treeIdx) = false;

obj = obj.deleteTrees(treeIndicesToDel);
end
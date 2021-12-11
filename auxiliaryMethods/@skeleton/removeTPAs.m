function obj = removeTPAs(obj, treeIndex)
%Remove three-point-annotations from tree.
%INPUT treeIndex: Index (not id!) of tree in skel.
%Author: Kevin M. Boergens <kevin.boergens@brain.mpg.de>
% NOTE This function removes nodes only if they have a comment
%      which must not be 'first' or 'end'.

am = createAdjacencyMatrix(obj,treeIndex);
am(logical(eye(size(am)))) = 1;
am2 = (am^2)>0;
list = find(sum(am) == 2 & sum(am2) == 3);
todelete = [];
for i = 1:length(list)
    com = lower(obj.nodesAsStruct{treeIndex}(list(i)).comment);
    if isempty(com) || (~isempty(strfind(com,'end'))) || (~isempty(strfind(com,'first')))
        continue;
    end
    todelete = [todelete find(am(list(i),:))];
end
for i = fliplr(sort(todelete))
    obj = deleteNode(obj,treeIndex,i);
end
end
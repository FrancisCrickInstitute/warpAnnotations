function obj = addTreesToGroup(obj, treeIdx, group)
%ADDTREETOGROUP Add a list of trees to a group.
% INPUT treeIdx: [Nx1] int or logical
%           Linear or logical indices of the trees.
%       groups: string or int
%           Name or id of the group.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ischar(group)
    id = obj.groups.id(strcmp(obj.groups.name, group));
    assert(~isempty(id), 'Group not found.');
else
    id = group;
end

obj.groupId(treeIdx) = id;


end


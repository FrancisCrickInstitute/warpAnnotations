function obj = deleteGroup(obj, group, mode, tr_mode)
%DELETEGROUP Delete a tree group.
% INPUT group: string or int
%           Name or id of the group to delete.
%       mode: string
%           Deletion mode wrt to other groups.
%           's': deletes only the single groups and appends all children to
%           the parent of the deleted group (Default)
%           'r': deletes the groups and all subgroups (recursive)
%       tr_mode: string
%           Deletion mode for the trees of the groups:
%           'd': Trees of the deleted groups are deleted as well.
%           'parent': Trees are assigned to the parent group.
%           'root': Trees are assigned to the root group.
%           'ign': Trees are ignored and their ids are unchanged and need
%               to be modified manually (Default)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('mode', 'var') || isempty(mode)
    mode = 's';
end

if ~exist('tr_mode', 'var') || isempty(tr_mode)
    tr_mode = 'ign';
end

if ischar(group)
    idx = strcmp(obj.groups.name, group);
    if sum(idx) > 1
        error('Several groups ''%s'' found. Please specify the id.', group);
    end
    assert(~isempty(idx), 'Group not found.');
else
    idx = obj.groups.id == group;
end

assert(sum(idx) == 1);
id = obj.groups.id(idx);
parent = obj.groups.parent(idx);
obj.groups = obj.groups(~idx, :);

switch mode
    case 'r'
        % nest and flatten again to remove all children
        id = [id; obj.groups.id(:)];
        obj.groups = obj.flattenOrNestGroup();
        obj.groups = obj.flattenOrNestGroup();
        id = setdiff(id, obj.groups.id); % deleted ids
    case 's'
        obj.groups.parent(obj.groups.parent == id) = parent;
    otherwise
        error('Unknown mode %s.');
end

switch tr_mode
    case 'ign'
        % nothing to do
    case 'd'
        toDel = ismember(obj.groupId, id);
        obj = obj.deleteTrees(toDel);
        obj.groupId(toDel) = [];
    case 'parent'
        obj.groupId(ismember(obj.groupId, id)) = parent;
    case 'root'
        obj.groupId(ismember(obj.groupId, id)) = NaN;
end
        

end


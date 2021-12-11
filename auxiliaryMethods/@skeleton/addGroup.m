function [obj, id] = addGroup(obj, name, parent, id)
%ADDGROUP Add a new group to the skeleton.
% INPUT name: string
%           Name of the group.
%       parent: (Optional) int or string
%           Id or name of the parent group.
%           (Default: NaN - i.e. root group)
%       id: (Optional) int
%           Id of the group.
%           (Default: largest group id + 1)
% OUTPUT id: int
%           The id of the group.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('parent', 'var') || isempty(parent)
    parent = NaN;
elseif ischar(parent)
    pname = parent;
    parent = obj.groups.id(strcmp(obj.groups.name, pname));
    if length(parent) > 1
        error('Several possible parents found. Please specify the id.');
    elseif isempty(parent)
        error('Parent ''%s'' not found.', pname);
    end
end

if ~exist('id', 'var') || isempty(id)
    if isempty(obj.groups) || isempty(obj.groups.id)
        id = 1;
    else
        id = max(obj.groups.id) + 1;
    end
elseif ~isempty(obj.groups)
    assert(~any(obj.groups.id == id), 'Duplicate id');
end

obj.groups = cat(1, obj.groups, {name, id, parent});

end


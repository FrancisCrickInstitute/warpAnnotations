function groups = flattenOrNestGroup(obj, groups)
%FLATTENGROUP Flatten the group and write it into a table.
% INPUT groups: (Optional) struct or table
%           The groups structure or flattened table (see output of this
%           function).
% OUTPUT groups: table or skeleton object
%           If groups is a nested struct, then it is converted into a table
%           representation with the columns 'name', 'id', and 'parent'
%           If groups is the flattened table representation is it converted
%           back into the nested struct representation.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if nargin < 2
    groups = obj.groups;
end

if isstruct(groups)
    groups = flatten(groups, NaN);
elseif istable(groups)
    groups.parent(isnan(groups.parent)) = 0;
    groups = nest(groups, 0);
end

end

function t = flatten(groups, parent)
parent = repelem(parent, length(groups.name))';
children = groups.children;
groups = rmfield(groups, 'children');
groups.parent = parent;
t = struct2table(groups);
for i = 1:length(children)
    if ~isempty(children{i})
        t2 = flatten(children{i}, groups.id(i));
        t = cat(1, t, t2);
    end
end
end

function s = nest(groups, parent)
idx = ismember(groups.parent, parent);
groups.children = cell(size(groups, 1), 1);
s = table2struct(groups(idx,[1:end-2, end]), 'ToScalar', true);
thisParents = groups.id(idx);
for i = 1:sum(idx)
    if any(groups.parent == thisParents(i))
        s.children{i} = nest(groups(~idx, :), thisParents(i));
    end
end

end

function groupViewer(obj)
%GROUPVIEWER Plot a diagram of the groups of a skeleton.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

groups = obj.groups;
if size(groups,1) == 0
    error('No Groups defined in skeleton')
end
nodes = zeros(length(groups.id), 1);
for u = unique(groups.parent(:)')
    nodes(groups.parent == u) = find(groups.id == u);
end

treeplot(nodes(:)');
hold on;
[x, y] = treelayout(nodes);

for i = 1:length(x)
    str = sprintf('%s (Id %d; %d trees)', groups.name{i}, ...
        groups.id(i), sum(obj.groupId == groups.id(i)));
    t = text(x(i) + 0.01, y(i) + 0.01, str);
    t.FontSize = 18;
end
axis off
end


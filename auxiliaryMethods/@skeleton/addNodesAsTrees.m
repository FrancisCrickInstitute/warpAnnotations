function skel = addNodesAsTrees(skel, nodes, name, comment,color)
%Add the specified nodes each in a single tree.
% INPUT nodes: [Nx3] array of integer containing the nodes.
%       name: (Optional) string or [Nx1] cell of strings
%           Name for each tree. If name is a string then it will get the
%           tree thingID as suffix.
%           If name is a cell array then a name must be provied for each
%           input node.
%           If the name a contains a '%' sign then sprintf with the
%           tree id is used to modify to corresponding cell.
%           (Default: Naming convention from addTree).
%       comment: [Nx1] cell
%           Cell array of the same length size(nodes, 1) containing a
%           comment for each node.
%       color: [Nx4] array of integer. (Default: same convention as addTree)
% OUTPUT skel: The updated Skeleton object.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
if ~exist('color', 'var') || isempty(color)
    color = repelem([1, 0, 0, 1], size(nodes,1), 1);
else
    assert(size(color,2)==4,'Colors should be RGBA values')
end

for i = 1:size(nodes,1)
    if ~exist('name','var') || isempty(name)
        curName = [];
    elseif iscell(name)
        if strfind(name{i}, '%')
            if isempty(skel.thingIDs)
                id = 1;
            else
                id = max(skel.thingIDs) + 1;
            end
            curName = sprintf(name{i}, id);
        else
            curName = name{i};
        end
    else
        if isempty(skel.thingIDs)
            id = 1;
        else
            id = max(skel.thingIDs) + 1;
        end
        if strfind(name, '%')
            curName = sprintf(name, id);
        else
            curName = sprintf('%s%03d', name, id);
        end
    end
    skel = skel.addTree(curName, nodes(i,:),'',color(i,:));
    if exist('comment', 'var') && ~isempty(comment)
        skel.nodesAsStruct{end}.comment = comment{i};
    end
end
end

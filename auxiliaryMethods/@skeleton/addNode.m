function [obj, addedEdges] = addNode(obj, tree_index, coords, ...
    connect_to, diameter, comment)
% Add a new node to a tree with at least one existing node.
% INPUT tree_index: The index of the tree, i.e. the index of
%       	the tree name in skel.names.
%       coords: [3x1] array of integer specifying the x, y and
%           z coordinate of the new node.
%       connect_to: (Optional)  [Nx1] int
%           Vector of integer specifying the row indices
%       	indices of the node in the tree to which the new
%       	node should be connected. Specify [] if this is the
%       	the first node in a tree.
%           NOTE Specifying multiple targets can lead to
%           cicles which is not supported and might lead to
%           (webknossos) errors.
%           (Default: the last node in the corresponding tree).
%       diameter: Diameter of the node. (Default: 1.5)
%       comment: (Optional) Comment to add to node.
%                (Default: '')

if tree_index > obj.numTrees()
    error('The specified tree does not exist.');
end

isFirstNode = isempty(obj.nodes{tree_index});
if isFirstNode && exist('connect_to', 'var') && ~isempty(connect_to)
    error('This is the first node in tree %d. Set connect_to to [].', ...
        tree_index);
elseif isFirstNode && ~exist('connect_to', 'var')
    connect_to = [];
elseif ~isFirstNode && (~exist('connect_to', 'var') || isempty(connect_to));
    connect_to = size(obj.nodes{tree_index}, 1);
else
    connect_to = connect_to(:);
end

%set default arguments
if ~exist('diameter','var') || isempty(diameter)
    diameter = 1.5;
end
if ~exist('comment','var') || isempty(comment)
    comment = '';
end

if any(coords ~= round(coords)) && obj.verbose
    warning('Coordinates are not integer.')
end

%get node coordinates
x = coords(1);
y = coords(2);
z = coords(3);

%add node
obj.nodes{tree_index}=[obj.nodes{tree_index}; x y z 1.5];
obj.nodesNumDataAll{tree_index}=[obj.nodesNumDataAll{tree_index}; obj.largestID+1 1.5 x y z 0 0 0];
ts.id=num2str(obj.largestID+1);
ts.radius=num2str(diameter);
ts.x=num2str(x);
ts.y=num2str(y);
ts.z=num2str(z);
ts.inVp='0';
ts.inMag='0';
ts.time='0';
ts.comment=comment;
if isFirstNode
    obj.nodesAsStruct{tree_index}=ts;
    addedEdges = [];
else
    obj.nodesAsStruct{tree_index}(end+1)=ts;
    addedEdges = repmat(length(obj.nodesAsStruct{tree_index}),length(connect_to),1);
    obj.edges{tree_index}=[obj.edges{tree_index}; connect_to addedEdges];
end
obj.largestID=obj.largestID+1;
end
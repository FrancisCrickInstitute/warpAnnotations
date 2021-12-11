function [obj, treeIdx] = addTree(obj, treeName, nodes, edges, color, ...
    treeIdxTarget, comments, group)
% Create a new tree. If no nodes and edges are specified the new
% tree wll be empty.
%
% INPUT tree_name: (Optional) string
%           Name of the tree. Can contain a "%d" that is replaced with the
%           tree id.
%           Default name is "Tree_id" with its id as suffix.
%       nodes: (Optional) [Nx3] or [Nx4] int
%           Global coordinates of nodes.
%           (Default: no nodes)
%       edges: (Optional) [Nx2] array of integer. Each row
%           defines an edge between the rows in nodes.
%           (Default: No edges, if nodes are empty. If nodes are supplied
%           but no edges then the nodes are connnected in the order in
%           nodes.)
%       color: (Optional) [1x4] double
%       	Tree color as RGBA values.
%       	(Default: [1, 0, 0, 1])
%       treeIdxTarget: (Optional)int
%           The linear index the new tree should be written to (replaces
%           the tree treeIdx if nonempty)
%       comments: (Optional) [Nx1] cell
%           Cell array with comments for the respective node.
%           (Default: no comments)
%       group: (Optional) int or string
%           Name (if unique) or id of the group for the tree.
%           (Default: NaN - root group).
%
% OUTPUT obj: The updated instance of obj.
%        treeIdx: The index of the new tree.
%
% NOTE No sanity checks are performed for nodes and edges and
% they should constitute a tree graph.
%
% See also Skeleton.addNode
%
% Written by
%   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
%   Alessandro Motta <alessandro.motta@brain.mpg.de>

if ~exist('treeIdxTarget','var') || isempty(treeIdxTarget)
    obj.nodes=[obj.nodes; cell(1)];
    obj.nodesAsStruct=[obj.nodesAsStruct; cell(1)];
    obj.nodesNumDataAll=[obj.nodesNumDataAll; cell(1)];
    obj.edges=[obj.edges; cell(1)];
    treeIdx = length(obj.nodes);
else
    treeIdx = treeIdxTarget;
end
if ~isempty(obj.thingIDs)
    thingID = max(obj.thingIDs)+1;
else
    thingID = 1;
end
obj.thingIDs = [obj.thingIDs; thingID];

% tree name
if ~exist('treeName','var') || isempty(treeName)
    treeName = sprintf('Tree_%03d', thingID);
else
    treeName = sprintf(treeName, thingID);
end

% tree color
if ~exist('color', 'var') || isempty(color)
    color = [1, 0, 0, 1];
else
    assert(size(color,2)==4,'Colors should be RGBA values')
end

% tree group
if ~exist('group', 'var') || isempty(group)
    group = NaN;
elseif ischar(group)
    gname = group;
    group = obj.groups.id(strcmp(obj.groups.name, gname));
    if length(group) > 1
        error('Several possible parents found. Please specify the id.');
    elseif isempty(group)
        error('Group ''%s'' not found.', gname);
    end
end
if obj.verbose
    fprintf('Adding new tree ''%s'' with thingID %d to Skeleton.\n', ...
        treeName, thingID);
end
obj.names = [obj.names(:); treeName];
obj.colors = [obj.colors; color(:)'];
obj.groupId = [obj.groupId; group];

%set nodes and edges in new
hasComments = exist('comments', 'var') && ~isempty(comments);
if exist('nodes','var')
    if any(any(nodes(:,1:3) ~= round(nodes(:,1:3)))) && obj.verbose
        warning('Not all nodes have integer coordinates.');
    end
    if size(nodes,2) == 3
        nodes(:,4) = 112;
    end
    if ~exist('edges','var') || isempty(edges)
        edges = [1:size(nodes,1) - 1;2:size(nodes,1)]';
    end
    obj.nodes{treeIdx} = nodes;
    obj.edges{treeIdx} = edges;
    obj.nodesNumDataAll{treeIdx} = zeros(size(nodes,1),8);
    obj.nodesNumDataAll{treeIdx}(:,1) = (1:size(nodes,1)) + obj.largestID;
    obj.nodesNumDataAll{treeIdx}(:,2) = 1.5;
    obj.nodesNumDataAll{treeIdx}(:,3:5) = nodes(:,1:3);
    
    nodeCount = size(nodes, 1);
    numToStrCellArray = @(vals) arrayfun( ...
        @(v) sprintf('%d', v), vals, 'UniformOutput', false);
    
    if ~hasComments
        % build empty comments
        comments = repmat({''}, 1, nodeCount);
    else
        comments(cellfun(@isempty,comments)) = {''};
    end
    
    ts = struct( ...
        'id', numToStrCellArray(obj.largestID + (1:nodeCount)), ...
        'x', numToStrCellArray(reshape(nodes(:, 1), 1, [])), ...
        'y', numToStrCellArray(reshape(nodes(:, 2), 1, [])), ...
        'z', numToStrCellArray(reshape(nodes(:, 3), 1, [])), ...
        'radius', numToStrCellArray(reshape(nodes(:, 4), 1, [])), ...
        'inVp', numToStrCellArray(zeros(1, nodeCount)), ...
        'inMag', numToStrCellArray(zeros(1, nodeCount)), ...
        'time', numToStrCellArray(zeros(1, nodeCount)), ...
        'comment', reshape(comments, 1, []));
    
    obj.nodesAsStruct{treeIdx} = ts;
    obj.largestID = obj.largestID + nodeCount;
end
end
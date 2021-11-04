function obj = scaleNodes(obj, t, tree_indices)
%Scale nodes in a Skeleton by a constant scaling
%vector.
% INPUT t: [1x3] vector of integer by which all node
%           coordinates will be scaled.
%           t is interpreted as mag (so if t=4, nodes_end = nodes./4 )
%       tree_indices: (Optional) Vector of integer specifying the
%           trees of interest.
%           (Default: all trees).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de> (for
% translateNodes)

if ~exist('tree_indices','var') || isempty(tree_indices)
    tree_indices = 1:length(obj.nodes);
end

if ~isrow(t)
    t = t';
end

for tr = tree_indices
    obj.nodes{tr}(:,1:3) = bsxfun(@rdivide,obj.nodes{tr}(:,1:3),t);
    obj.nodesNumDataAll{tr}(:,3:5) = obj.nodes{tr}(:,1:3);
    x = cellfun(@num2str,num2cell(obj.nodes{tr}(:,1)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).x] = x{:};
    y = cellfun(@num2str,num2cell(obj.nodes{tr}(:,2)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).y] = y{:};
    z = cellfun(@num2str,num2cell(obj.nodes{tr}(:,3)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).z] = z{:};
end

% update scale
obj.scale = obj.scale .* t;
end
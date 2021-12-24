function obj = addTreeFromSkel(obj, skel, treeIndices, treeNames)
% ADDTREEFROMSKEL Add trees from another skeleton object.
%
% INPUT skel: A Skeleton object different from the one calling
%             this function.
%       treeIndices: (Optional) Linear indices of the trees in
%             skel to add to obj.
%             (Default: all trees in skel).
%       treeNames: (Optional) [Nx1] cell or string
%           Cell array of same length as treeIndices containing the names
%           for the trees in skel which are added to obj.
%           Alternatively, a string can be for all trees, which can contain
%           "%d" which is replaced by the tree id.
%           (Default: Tree names in skel).
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end
treeIndices = treeIndices(:)';

if ~exist('treeNames', 'var')
    treeNames = skel.names(treeIndices);
elseif ischar(treeNames)
    treeNames = repmat({treeNames}, length(treeIndices), 1);
elseif iscell(treeNames) && (length(treeNames) ~= length(treeIndices))
    error(['A name must be specified for each tree which is added ' ...
            'to the skeleton.']);
end

% add trees to obj
for tr = 1:length(treeIndices)
    obj = obj.addTree(treeNames{tr}, skel.nodes{treeIndices(tr)}, ...
        skel.edges{treeIndices(tr)});
    [obj.nodesAsStruct{end}.comment] = ...
        skel.nodesAsStruct{treeIndices(tr)}.comment;
end

end

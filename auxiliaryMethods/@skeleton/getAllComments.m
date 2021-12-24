function [comments, treeIdx, nodeIdx] = getAllComments( skel, treeIndices )
%GETALLCOMMENTS Get the comment strings for the specified trees.
% INPUT treeIndices: [Nx1] int or [Nx1] logical
%           Linear or logical indices for the trees of interest.
%           (Default: all trees)
% OUTPUT comments: [Nx1] cell
%           Cell array of string containing all comments for each specified
%           tree.

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if islogical(treeIndices)
    treeIndices = find(treeIndices);
end

comments = cell(length(treeIndices), 1);
nodeIdx = cell(length(treeIndices), 1);
treeIdx = cell(length(treeIndices), 1);
for i = 1:length(treeIndices)
    theseComments = {skel.nodesAsStruct{treeIndices(i)}.comment}';
    treeIdx{i} = repmat(i, sum(~cellfun(@isempty, theseComments)), 1);
    nodeIdx{i} = find(~cellfun(@isempty, theseComments));
    comments{i} = theseComments(nodeIdx{i});
end
treeIdx = cat(1, treeIdx{:});
nodeIdx = cat(1, nodeIdx{:});
comments = cat(1, comments{:});


end


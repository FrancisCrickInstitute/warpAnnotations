function [ucomments, comments] = getUniqueComments( skel, treeIndices )
%GETUNIQUECOMMENTS Get the unique comment strings for the specified trees.
% INPUT treeIndices: [Nx1] int or [Nx1] logical
%           Linear or logical indices for the trees of interest.
%           (Default: all trees)
% OUTPUT ucomments: table
%           Table containing the unique comments with counts for each
%           unique comment.
%        comments: [Nx1] cell
%           Cell array of string containing all comments for the specified
%           trees converted to categorical variables. To search for a
%           comment simply use
%           comments{i} == 'comment_to_search_for'.
%           (see also skeleton.replaceComments)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if islogical(treeIndices)
    treeIndices = find(treeIndices);
end

comments = cell(length(treeIndices), 1);
for i = 1:length(treeIndices)
    comments{i} = {skel.nodesAsStruct{treeIndices(i)}.comment}';
end

commentsAll = categorical(vertcat(comments{:}));
counts = countcats(commentsAll);
ucomments = categories(commentsAll);
ucomments = table(ucomments, counts, ...
    'VariableNames', {'Comments', 'Count'});
comments = cellfun(@categorical, comments, 'UniformOutput', false);
end


function skel = replaceComments( skel, comment, rep, searchMode, ...
    repMode, treeIndices,nodeIdx)
%REPLACECOMMENTS Replace comments.
% INPUT comment: string
%           The original comment.
%       rep: string
%           Thre replacement string.
%       searchMode: (Optional) string
%           see mode in skeleton.getNodesWithComment
%       repMode: (Optional) string
%           Replacement mode
%           'complete': The whole comment is replaced by the new one.
%               (Default)
%           'partial': Replace only the exact comment string with rep.
%       treeIndices: [Nx1] int or [Nx1] logical
%           Linear or logical indices of the tree of interest.
%           (Default: all trees)
%       nodeIdx: Ids of the nodes you would like to replace
%           (Default: all nodes containing the comment)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('searchMode', 'var') || isempty(searchMode)
    searchMode = [];
end

if ~exist('repMode', 'var') || isempty(repMode)
    repMode = 'complete';
end

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if islogical(treeIndices)
    treeIndices = find(treeIndices);
end
if ~exist('nodeIdx', 'var') || isempty(nodeIdx)
nodeIdx = skel.getNodesWithComment(comment, treeIndices, searchMode);
end

if ~iscell(nodeIdx)
    nodeIdx = {nodeIdx};
end

for i = 1:length(treeIndices)
    for j = 1:length(nodeIdx{i})
        switch repMode
            case 'complete'
                skel.nodesAsStruct{treeIndices(i)}(nodeIdx{i}(j)). ...
                    comment = rep;
            case 'partial'
                skel.nodesAsStruct{treeIndices(i)}(nodeIdx{i}(j)). ...
                    comment = ...
                    strrep(skel.nodesAsStruct{treeIndices(i)} ...
                    (nodeIdx{i}(j)).comment, comment, rep);
            otherwise
                error('Unknown replacement mode %s.', repMode)
        end
    end
end


end


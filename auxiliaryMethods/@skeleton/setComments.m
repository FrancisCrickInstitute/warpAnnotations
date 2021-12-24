function obj = setComments( obj, treeIdx, nodeIdx, comments )
%SETCOMMENTS Set comments for the specified nodes.
%
% INPUT treeIdx: int
%           Index of the target tree.
%       nodeIdx: [Nx1] int or logical
%           Linear or logical indices of nodes.
%       comments: string or [Nx1] cell
%           Comment or list of comments for the corresponding nodes.
%           If there are several nodes indices and comments is a string or
%           a cell of length one then this commen will be used for all
%           nodes.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ischar(comments)
    comments = {comments};
end

if islogical(nodeIdx)
    nodeIdx = find(nodeIdx);
end

if length(nodeIdx) > 1 && length(comments) == 1
    comments = repmat(comments, length(nodeIdx), 1);
elseif length(nodeIdx) ~= length(comments)
    error('Specify a comment for each node.');
end

for i = 1:length(nodeIdx)
    obj.nodesAsStruct{treeIdx}(nodeIdx(i)).comment = comments{i};
end

end


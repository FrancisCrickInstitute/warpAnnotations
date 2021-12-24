function nodesIdx = getNodesWithComment(skel, comment, treeIndices, mode,returnCell)
%Get all nodes with a comment from a tree.
% INPUT comment: string
%           String to look for in the node comments.
%       treeIndices: [Nx1] int or [Nx1] logical
%           Linear or logical indices of the tree of interest.
%           (Default: all trees)
%       mode: (Optional) string
%           Specify search mode
%           'exact': Exactly matches the comment (Default)
%           'partial': comment is partially contained in a node
%           	comment.
%           'insensitive': Case-insensitive string matching
%           'regexp': regular expression matching
%       returnCell:in case of 1 output keep it as a cell
% OUTPUT nodesIdx: [Nx1] int or [Nx1] cell
%           Cell array of row vector of linear indices of the nodes with
%           the comment in the specified trees. If only one tree is
%           specified then an integer array is returned (compatibility with
%           old version).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if islogical(treeIndices)
    treeIndices = find(treeIndices);
end

if ~exist('mode','var') || isempty(mode)
    mode = 'exact';
end
%Make sure the output is a cell default false
if ~exist('returnCell','var') || isempty(returnCell)
    returnCell = false';
end

% default to exact match
modeFun = @(x) strcmp(x, comment);

switch mode
    case 'partial'
        modeFun = @(x) contains(x, comment);
    case 'exact'
        modeFun = @(x) strcmp(x, comment);
    case 'insensitive'
        modeFun = @(x) strcmpi(x, comment);
    case 'regexp'
        modeFun = @(x) ~isempty(regexp(x, comment, 'once'));
end


nodesIdx = cell(length(treeIndices), 1);
for i = 1:length(treeIndices)
    
    % extract comments
    commentCell = {skel.nodesAsStruct{treeIndices(i)}.comment};
    
    % get nodes
    nodesIdx{i} = find(cellfun(modeFun, commentCell))';
end
if returnCell
    return
else
if length(nodesIdx) == 1
    nodesIdx = nodesIdx{1};
end
end

end

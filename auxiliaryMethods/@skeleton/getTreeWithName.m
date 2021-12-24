function treeIdx = getTreeWithName( skel, name, mode )
%Get all nodes with a name from a tree.
% INPUT name: string
%           String to look for in the tree names.
%       mode: (Optional) string
%           Specify search mode
%           'exact': Exactly matches the name (Default)
%           'partial': name is partially contained in a node
%           	name.
%           'insensitive': Case-insensitive string matching
%           'regexp': regular expression matching
% OUTPUT treeIdx: [Nx1] double
%           with the Tree ID's satisfying the name condiftion
% Author: Ali Karimi <ali.karimi@brain.mpg.de>
if ~exist('mode','var') || isempty(mode)
    mode = 'exact';
end

% default to exact match
modeFun = @(x) strcmp(x, name);


switch mode
    case 'partial'
        modeFun = @(x) contains(x, name);
    case 'exact'
        modeFun = @(x) strcmp(x, name);
    case 'insensitive'
        modeFun = @(x) strcmpi(x, name);
    case 'regexp'
        modeFun = @(x) ~isempty(regexp(x, name, 'once'));
    case 'first'
        modeFun=  @(x) strncmp(x,name,size(name,2));
    otherwise
        error('search mode for treename is incorrect');
end
        treeIdx = find(cellfun(modeFun,skel.names)); 
  
end


function skel = deleteTreeWithName( skel, name, mode )
%DELETETREEWITHNAME Delete trees based on their name.
% INPUT name: string
%           The string based on which the tree names are searched.
%       mode: (Optional) string
%           Specify search mode
%           'exact': Exactly matches the comment (Default)
%           'partial': comment is partially contained in a node
%           	comment.
%           'insensitive': Case-insensitive string matching
%           'regexp': regular expression matching
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('mode','var') || isempty(mode)
    mode = 'exact';
end

switch mode
    case 'partial'
        fStrcomp = @(x) contains(x, name);
    case 'exact'
        fStrcomp = @(x) strcmp(x, name);
    case 'insensitive'
        fStrcomp = @(x) strcmpi(x, name);
    case 'regexp'
        fStrcomp = @(x) ~isempty(regexp(x, name, 'once'));
    otherwise
        error('Unknown mode %s.', mode);
end

toDel = cellfun(fStrcomp, skel.names);
skel = skel.deleteTrees(toDel);

end


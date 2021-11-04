function skel = sortTreesByLength( skel, direction )
%SORTTREESBYLENGTH Reorder trees in skeleton by path length.
% INPUT direction: (Optional) string
%           Direction of sorting as 'descend' or 'ascend'.
%           (Default: 'descending')
% OUTPUT skel: skeleton object
%           The udpated skeleton object.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('direction', 'var') || isempty(direction)
    direction = 'descend';
end

l = skel.pathLength();
[~,idx] = sort(l, direction);
skel = skel.reorderTrees(idx);

end


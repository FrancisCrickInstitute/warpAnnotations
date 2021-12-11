function skel = sortTreesById( skel )
%SORTTREESBYID Sort the trees in a skeleton by id.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[~,idx] = sort(skel.thingIDs);
skel = skel.reorderTrees(idx);

end


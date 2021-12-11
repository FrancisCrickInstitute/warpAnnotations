function treeIdx = getTreeIdx(skel, id)
%Get the tree index using the tree id.
% INPUT id: Numerical id of tree of interest.
% OUTPUT treeIDx: Integer specifying the index of the tree in
%                 skel. Returns [] if id was not found.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

treeIdx = find(skel.thingIDs == id);
end
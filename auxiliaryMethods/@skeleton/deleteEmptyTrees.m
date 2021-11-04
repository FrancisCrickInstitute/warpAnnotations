function skel = deleteEmptyTrees( skel )
%DELETEEMPTYTREES Delete all empty trees of a skeleton object.
% Trees are considered empty if skel.nodes is empty for the corresponding
% tree.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

toDel = cellfun(@isempty, skel.nodes);

%delete tree
skel.nodes(toDel) = [];
skel.nodesAsStruct(toDel) = [];
skel.nodesNumDataAll(toDel) = [];
skel.thingIDs(toDel) = [];
skel.names(toDel) = [];
skel.colors(toDel) = [];
skel.edges(toDel) = [];

end


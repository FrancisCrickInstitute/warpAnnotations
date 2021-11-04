function skel = reorderTrees( skel, idx )
%REORDERTREES Change the order of trees in the skeleton.
% INPUT idx: [Nx1] int
%           Permutation of the vector 1:skel.numTrees().
% OUTPUT skel: skeleton object.
%           The udpated skeleton object.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%some sanity checks
if max(idx) > skel.numTrees() || min(idx) < 0 || any(round(idx) ~= idx) || ...
        any(accumarray(idx(:), 1) ~= 1)
    error('Invalid input idx.');
end

skel.nodes = skel.nodes(idx);
skel.nodesAsStruct = skel.nodesAsStruct(idx);
skel.nodesNumDataAll = skel.nodesNumDataAll(idx);
skel.edges = skel.edges(idx);
skel.thingIDs = skel.thingIDs(idx);
skel.names = skel.names(idx);
skel.colors = skel.colors(idx);

end


function skel = mergeSkels(skel, skel2)
%Merge two Skeletons into a single one.
% INPUT skel: A Skeleton object. Everything contained in this
%             Skeleton object will be unmodified after merging.
%       skel2: A Skeleton object or an nml-path. IDs and tree
%              names of this Skeleton will shift depending on
%              the nodes and number of trees in skel.
% OUTPUT skel: A Skeleton object containing skel and skel2.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ischar(skel2)
    skel2 = skeleton(skel2, false, skel.nodeOffset, skel.verbose);
end

skel2 = skel2.resetNodeIDs(skel.largestID + 1);

%reset tree IDs of skel2
if ~isempty(skel.thingIDs)
    skel2.thingIDs = (1:skel2.numTrees())' + max(skel.thingIDs);
end

%cat everything to skel
skel.nodes = [skel.nodes; skel2.nodes];
skel.nodesAsStruct = [skel.nodesAsStruct; skel2.nodesAsStruct];
skel.nodesNumDataAll = [skel.nodesNumDataAll; skel2.nodesNumDataAll];
skel.edges = [skel.edges; skel2.edges];
skel.branchpoints = [skel.branchpoints; skel2.branchpoints];
skel.names = [skel.names; skel2.names];
skel.colors = [skel.colors; skel2.colors];
skel.thingIDs = [skel.thingIDs; skel2.thingIDs];
skel.largestID = skel2.largestID;

% add groups of second skeleton with larger id
if ~isempty(skel.groupId)
    toAddId = max(skel.groupId);
else
    toAddId = 0;
end
skel.groupId = [skel.groupId; toAddId + skel2.groupId];
groups = skel2.groups;
groups.id = groups.id + toAddId;
groups.parent = groups.parent + toAddId;
skel.groups = cat(1, skel.groups, groups);
end

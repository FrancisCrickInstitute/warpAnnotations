function [ skel ] = sortNodesById( skel )
%SORTNODESBYID Sort all nodes within each tree by id.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

for tr = 1:skel.numTrees()
    id = skel.nodesNumDataAll{tr}(:,1);
    [sid,I] = sort(id);
    revorder = I;
    if any(sid ~= id) %requires sorting
        
        %sort nodes and nodesNumData all
        skel.nodes{tr} = skel.nodes{tr}(I,:);
        skel.nodesNumDataAll{tr} = skel.nodesNumDataAll{tr}(I,:);
        skel.nodesAsStruct{tr} = skel.nodesAsStruct{tr}(I);
        %replace node indices in edges
        revorder(I) = 1:skel.numNodes(tr);
        skel.edges{tr} = revorder(skel.edges{tr});
    end
end

end


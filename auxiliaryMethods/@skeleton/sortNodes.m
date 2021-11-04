function [ skel ] = sortNodes( skel, tr, order )
%SORTNODES Sort all nodes within a tree by I.
if numel(order) ~= skel.numNodes(tr)
   error('Index vector has not same size than node vector')
end
    %sort nodes and nodesNumData all
    skel.nodes{tr} = skel.nodes{tr}(order,:);
    skel.nodesNumDataAll{tr} = skel.nodesNumDataAll{tr}(order,:);
    skel.nodesAsStruct{tr} = skel.nodesAsStruct{tr}(order);
    %replace node indices in edges
    revorder(order) = 1:skel.numNodes(tr);
    skel.edges{tr} = revorder(skel.edges{tr});
end


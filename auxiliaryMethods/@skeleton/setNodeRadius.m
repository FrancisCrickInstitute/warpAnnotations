function  skel  = setNodeRadius( skel,tree_index,nodeRadius)
%SETNodes Summary of this function goes here
%   from Kevin's skeleton class

    skel.nodes{tree_index}(:, 4) = nodeRadius;
    skel.nodesAsStruct{tree_index}=arrayfun(@(x) ...
        setfield(skel.nodesAsStruct{tree_index}(x),'radius',nodeRadius),...
        1:length(skel.nodesAsStruct{tree_index}));
    %Seems like this is the one that writeNml actually uses:
    skel.nodesNumDataAll{tree_index}(:,2)=nodeRadius;
    
end
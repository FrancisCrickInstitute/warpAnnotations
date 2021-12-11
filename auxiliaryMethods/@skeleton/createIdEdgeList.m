function li=createIdEdgeList(obj,tree_id)
li=[obj.nodesNumDataAll{tree_id}(obj.edges{tree_id}(:,1),1) obj.nodesNumDataAll{tree_id}(obj.edges{tree_id}(:,2),1)];
end
function obj=switchIDs(obj, tree_index, index1, index2)
temp=obj.nodes{tree_index}(index1,:);
obj.nodes{tree_index}(index1,:)=obj.nodes{tree_index}(index2,:);
obj.nodes{tree_index}(index2,:)=temp;

temp=obj.nodesNumDataAll{tree_index}(index1,2:end); %1 is ID
obj.nodesNumDataAll{tree_index}(index1,2:end)=obj.nodesNumDataAll{tree_index}(index2,2:end);
obj.nodesNumDataAll{tree_index}(index2,2:end)=temp;

temp=obj.nodesAsStruct{tree_index}(index1);
obj.nodesAsStruct{tree_index}(index1)=obj.nodesAsStruct{tree_index}(index2);
obj.nodesAsStruct{tree_index}(index2)=temp;

temp=obj.nodesAsStruct{tree_index}(index1).id; %revert ID flip
obj.nodesAsStruct{tree_index}(index1).id=obj.nodesAsStruct{tree_index}(index2).id;
obj.nodesAsStruct{tree_index}(index2).id=temp;

temp=obj.edges{tree_index};
obj.edges{tree_index}(temp==index1)=index2;
obj.edges{tree_index}(temp==index2)=index1;
end
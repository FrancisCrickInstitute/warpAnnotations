function obj=splitTree(obj, tree_index, edge_index)
twonodes=obj.edges{tree_index}(edge_index,:);
edgetemp=obj.edges{tree_index}([1:edge_index-1, edge_index+1:end],:);
obj=addTree(obj);
% make adj matrix
am=zeros(size(obj.nodes{tree_index},1));
am((edgetemp(:,1)-1)*size(obj.nodes{tree_index},1)+edgetemp(:,2))=true;
am=reshape(am,size(obj.nodes{tree_index},1),size(obj.nodes{tree_index},1));
am1 = am';
am=(am+am')+eye(size(am));
while true
    am2=am*am;
    am3 = am2;
    am3(am3>0)=1;
    if am3==am
        break;
    end
    am=am3;
end
% Find all members of both subnetworks
inds1 = find(am(twonodes(1),:));
inds2 = find(am(twonodes(2),:));
% Prepare Edge References
for i = 1:size(obj.edges{tree_index},1)
    edgeRef(i,:) = [obj.nodesNumDataAll{tree_index}(obj.edges{tree_index}(i,1),1) obj.nodesNumDataAll{tree_index}(obj.edges{tree_index}(i,2),1)];
end
% Write Nodes
temp = obj.nodes{tree_index};
obj.nodes{tree_index}=temp(inds1,:);
obj.nodes{length(obj.thingIDs)}=temp(inds2,:);
temp = obj.nodesNumDataAll{tree_index};
ndai = [temp, [1:size(temp,1)]'];
obj.nodesNumDataAll{tree_index}=temp(inds1,:);
obj.nodesNumDataAll{length(obj.thingIDs)}=temp(inds2,:);
temp = obj.nodesAsStruct{tree_index};
obj.nodesAsStruct{tree_index}=temp(inds1);
obj.nodesAsStruct{length(obj.thingIDs)}=temp(inds2);
% Write Edges
obj.edges{tree_index} = [];
obj.edges{length(obj.thingIDs)} = [];
for i = 1:size(edgeRef,1)
    [a1 b1] = ismember(edgeRef(i,:),obj.nodesNumDataAll{tree_index}(:,1));
    [a2 b2] = ismember(edgeRef(i,:),obj.nodesNumDataAll{length(obj.thingIDs)}(:,1));
    if a1>0
        obj.edges{tree_index} = [obj.edges{tree_index}; b1];
    elseif a2>0
        obj.edges{length(obj.thingIDs)} = [obj.edges{length(obj.thingIDs)}; b2];
    end
end
end

function am=createWeightedAdjacencyMatrix(obj,tree_index)
am=createAdjacencyMatrix(obj,tree_index);
dist=zeros([size(am) 3]);
for dim=1:3 %get distance between all point pairs
    dist(:,:,dim)=feval(@(y)y.^2,...
        feval(@(x)repmat(x,1,numel(x))-repmat(x',numel(x),1),...
        obj.scale(dim)*obj.nodes{tree_index}(:,dim)));
end
am=sparse(sqrt(sum(dist,3)).*am);

end

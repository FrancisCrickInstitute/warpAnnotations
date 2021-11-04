function obj = invertDimension(obj, dsize, dim)

tree_indices = 1:length(obj.nodes);
for tr = tree_indices
    obj.nodes{tr}(:,dim) = dsize(dim) - obj.nodes{tr}(:,dim);
    obj.nodesNumDataAll{tr}(:,3:5) = obj.nodes{tr}(:,1:3);
    x = cellfun(@num2str,num2cell(obj.nodes{tr}(:,1)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).x] = x{:};
    y = cellfun(@num2str,num2cell(obj.nodes{tr}(:,2)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).y] = y{:};
    z = cellfun(@num2str,num2cell(obj.nodes{tr}(:,3)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).z] = z{:};
end

end


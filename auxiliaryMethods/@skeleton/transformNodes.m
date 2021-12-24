function obj = transformNodes(obj, landmark_filename, inverse)

if nargin < 3
    inverse = false;
end

if ~strcmp(landmark_filename, 'none')  
    import TransformPoints2.*
    tp = TransformPoints2();
    if inverse
        transform_function = @(x) tp.inverse_transform(landmark_filename, x);
    else
        transform_function = @(x) tp.transform(landmark_filename, x);
    end

    tree_indices = 1:length(obj.nodes);
    for tr = tree_indices
        obj.nodes{tr}(:,1:3) = transform_function(obj.nodes{tr}(:,1:3));
        obj.nodesNumDataAll{tr}(:,3:5) = obj.nodes{tr}(:,1:3);
        x = cellfun(@num2str,num2cell(obj.nodes{tr}(:,1)),'UniformOutput',false);
        [obj.nodesAsStruct{tr}(:).x] = x{:};
        y = cellfun(@num2str,num2cell(obj.nodes{tr}(:,2)),'UniformOutput',false);
        [obj.nodesAsStruct{tr}(:).y] = y{:};
        z = cellfun(@num2str,num2cell(obj.nodes{tr}(:,3)),'UniformOutput',false);
        [obj.nodesAsStruct{tr}(:).z] = z{:};
    end
end
end


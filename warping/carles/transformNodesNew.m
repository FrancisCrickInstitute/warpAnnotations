function obj = transformNodesNew(obj, landmark_filename, targetScale, targetExpName)

import TransformPoints2.*
tp = TransformPoints2();
transform_function = @(x) tp.transform(landmark_filename, x);

tree_indices = 1:length(obj.nodes);
for tr = tree_indices
    % apply warp on nm-values
    obj.nodes{tr}(:,1:3) = transform_function(obj.nodes{tr}(:,1:3).*obj.scale);
    % convert warped nm into pixel values
    obj.nodes{tr}(:,1:3) = obj.nodes{tr}(:,1:3)./targetScale;
    % update all node entries in the skel structure
    obj.nodesNumDataAll{tr}(:,3:5) = obj.nodes{tr}(:,1:3);
    x = cellfun(@num2str,num2cell(obj.nodes{tr}(:,1)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).x] = x{:};
    y = cellfun(@num2str,num2cell(obj.nodes{tr}(:,2)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).y] = y{:};
    z = cellfun(@num2str,num2cell(obj.nodes{tr}(:,3)),'UniformOutput',false);
    [obj.nodesAsStruct{tr}(:).z] = z{:};
    
end

% set new skel parameters
obj.scale = targetScale;
obj.parameters.experiment.name = targetExpName;
obj.parameters.scale.x = num2str(targetScale(1));
obj.parameters.scale.y = num2str(targetScale(2));
obj.parameters.scale.z = num2str(targetScale(3));


% todo: import parameters from template skeleton in the target space -or
% not.

end


function obj_new = transformVirtualDatasetToOriginal(obj)

obj_new = obj;
dataset_parts = strsplit(obj.dataset, '_');
if strcmp(dataset_parts{end}(1:3), 'mag')
    dataset = strjoin(dataset_parts(1:end-1), '_');
    resolution = str2num(dataset_parts{end}(4:end));
    obj_new.dataset = dataset;
    obj_new.scale = obj.scale ./ resolution;
    for i=1:length(obj_new.vertices)
    	obj_new.vertices{i} = obj.vertices{i} .* resolution;
    end
end

end


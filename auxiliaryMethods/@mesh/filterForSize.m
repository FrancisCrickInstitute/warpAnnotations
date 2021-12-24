function obj_new = filterForSize(obj, threshold)

idx = obj.volumes < threshold;
obj_new = obj.deleteMeshes(idx);

end


function obj_new = deleteMeshes(obj, idx)

obj_new = obj;
obj_new.cellIds = obj.cellIds(~idx);
obj_new.cellCCs = obj.cellCCs(~idx);
obj_new.volumes = obj.volumes(~idx);
obj_new.surfaceAreas = obj.surfaceAreas(~idx);
obj_new.vertices = obj.vertices(~idx);
obj_new.faces = obj.faces(~idx);
obj_new.nrMeshes = length(obj_new.vertices);

end


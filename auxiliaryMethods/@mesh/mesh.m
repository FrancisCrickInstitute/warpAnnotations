classdef mesh
    %Mesh Class for easier handling of meshes in matlab
    properties
    	% Global properties for a mesh file
	nrMeshes = 0;
	scale = [NaN NaN NaN];
	dataset = '';
	% Properties per cell ID and cc
	cellIds = [];
	cellCCs = [];
	volumes = [];
	surfaceAreas = [];
        vertices = {};
        faces = {};
    end

    methods
        function obj = mesh(filename)
	    temp = load(filename);
	    obj.nrMeshes = length(temp.meshes);
	    obj.scale = temp.scale;
	    obj.dataset = temp.dataset;
	    for i=1:length(temp.meshes)
		obj.cellIds(i) = temp.meshes{i}.cellIds;
		obj.cellCCs(i) = temp.meshes{i}.cellCC;
	    	obj.volumes(i) = temp.meshes{i}.volume;
	    	obj.surfaceAreas(i) = temp.meshes{i}.surfaceArea;
	    	obj.vertices{i} = temp.meshes{i}.vertices;
	    	obj.faces{i} = temp.meshes{i}.faces;
	    end
	end
    end
end


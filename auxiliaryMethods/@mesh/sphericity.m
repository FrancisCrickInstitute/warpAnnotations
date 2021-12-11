function sphericity = sphericity(obj)

sphericity = cell(obj.nrMeshes,1);
for i=1:obj.nrMeshes
    % See: https://en.wikipedia.org/wiki/Sphericity
    sphericity{i} = pi^(1/3)*(6*obj.volumes{i})^(2/3)/obj.surfaceAreas{i};
end

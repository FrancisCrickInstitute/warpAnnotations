function writePLY(obj, outputFilename, colors)

if nargin < 3
    colors = lines(obj.nrMeshes);
end

for i=1:obj.nrMeshes
    toWrite = cell(1);
    toWrite{1} = struct;
    toWrite{1}.vertices = bsxfun(@times, obj.vertices{i}, obj.scale);
    toWrite{1}.faces = obj.faces{i};
    Visualization.writePLY(toWrite, colors(i,:), strrep(outputFilename, '.ply', [num2str(i, '%5.5u') '.ply']));
end

end


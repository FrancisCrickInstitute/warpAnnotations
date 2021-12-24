function plot(obj, colors, alpha, treeIndices)
    if nargin < 4
        treeIndices = true(obj.nrMeshes,1);
    end
    for i=1:length(obj.vertices)
        if treeIndices(i)
		p = patch('Vertices', bsxfun(@times, obj.vertices{i}, obj.scale), 'Faces', obj.faces{i}, ...
			  'FaceColor', colors(i,:), 'FaceAlpha', alpha, 'EdgeColor', 'none');
	end
    end
end

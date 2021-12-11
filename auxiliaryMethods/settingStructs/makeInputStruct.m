function struct = makeInputStruct(folder, prefix, region, cubeFlag)

if nargin > 2
	if cubeFlag
		struct.cubes = region;
		struct.bbox(:,1) = [region(:,1)*128 + 1 (region(:,2)+1)*128];
	else
		struct.bbox = region;
		struct.cubes = [floor(( struct.bbox(:,1) - 1) / 128 ) ceil( struct.bbox(:,2) / 128 ) - 1];
	end
end
struct.root = folder;
struct.prefix = prefix;

end

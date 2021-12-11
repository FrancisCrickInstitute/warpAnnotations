function supercubeWriter(rootPath)
% Write supercubes for a normal raw wkw dataset using standard parameters
param.root = rootPath;
param.backend = 'wkwrap';
createResolutionPyramid(param);

end

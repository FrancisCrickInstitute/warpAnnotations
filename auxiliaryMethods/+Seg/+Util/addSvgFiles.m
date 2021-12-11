function p = addSvgFiles( p )
%ADDSVGFILES Add the default path of the supervoxel graph files in the
% segmentation main folder.
% INPUT p: struct
%           The segmentation parameter struct.
% OUTPUT p: struct
%           The segmentation parameter struct containing the additional
%           field 'svg' with paths to the most frequently used svg files.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

p.svg.edgeFile = fullfile(p.saveFolder, 'globalEdges.mat');
p.svg.contProbFile = fullfile(p.saveFolder, ...
    'globalNeuriteContinuityProb.mat');
p.svg.synScoreFile = fullfile(p.saveFolder, 'globalSynScores.mat');
p.svg.segmentMetaFile = fullfile(p.saveFolder, 'segmentMeta.mat');
p.svg.borderMetaFile = fullfile(p.saveFolder, 'globalBorder.mat');
p.svg.graphFile = fullfile(p.saveFolder, 'graph.mat');
p.svg.correspondenceFile = fullfile(p.saveFolder, 'correspondences.mat');
p.svg.aggloPredFile = fullfile(p.saveFolder, 'segmentAggloPredictions.mat');

end


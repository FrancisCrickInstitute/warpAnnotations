function [neighborIDs, synScores, intSize, intCom, borders, ...
    gpProb] = getSynapsePredictions( pCube, areaThres, idConv, mode )
%GETSYNAPSEPREDICTIONS Load synapse predictions from local cube.
% INPUT pCube: A local segmentation cube parameter struct
%           (e.g. p.local(i)).
%       areaThres: (Optional) Area threshold which is applied to
%       	interfaces/borders.
%       	(Default: 150. Use the value here that has been used for
%       	interface classification).
%       idConv: (Optional) String specifying ids conversion mode for
%           neighborIDs loaded from pCube.edgeFile.
%           (Default: no conversion)
%           see also Seg.Local.localGlobalIDConversion
%       mode: (Optional) Specify mode as string
%           'full': The outputs are with respect to all edges in the local
%               segmentation cube. If an edge size is below the area
%               threshold than the corresponding row in synScores contains
%               NaNs.
%           'valid': (Default) Only edges above the area threshold are
%               considered and other edges are removed from all output
%               variables.
% OUTPUT neighborIDs: [Nx2] array containing the IDs of all pairs of
%           interfaces with an area above the threshold.
%        synScores: [Nx2] array of double containing the synapse scores for
%           respective neighbors in neighborIDs. The first column
%           corresponds to the pre-post score (i.e. the score for synapse
%           from neighborIDs(i,1) to neighborsIDs(i,2)) and the second
%           column to the post-pre score.
%        intSize: [Nx1] array of integer containing the size of the
%           respective interface.
%        intCom: [Nx3] array of integer containing the global
%           coordinates of the respective interface.
%        borders: [Nx1] struct array of the borders for the corresponding
%           rows in synScores.
%        gpProb: [Nx1] array of double containing the gp probabilities of
%           the respective neighbors in neighborIDs are connected. 
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('mode','var') || isempty(mode)
    mode = 'valid';
end

%load data
m = load(pCube.borderFile);
borders = m.borders;
m = load(pCube.edgeFile);
edges = m.edges;
m = load(pCube.synapseFile);
synScores = single(m.scores);

%apply area threshold
if ~exist('areaThres','var') || isempty(areaThres)
    areaThres = 150;
end
area = [borders(:).Area];
switch mode
    case 'full'
        keepInterfaces = true(length(area),1);
        tmp = NaN(length(keepInterfaces),2,'single');
        tmp(area > areaThres,:) = synScores;
        synScores = tmp;
    case 'valid'
        keepInterfaces = area > areaThres;
        borders = borders(keepInterfaces);
    otherwise
        error('Unknown mode %s.',mode);
end

%define outputs
intSize = area(keepInterfaces)';
neighborIDs = edges(keepInterfaces,:);
intCom = cell2mat({borders.Centroid}');
intCom = bsxfun(@plus, intCom, pCube.bboxSmall(:,1)' - [1, 1, 1]);
intCom = uint16(intCom);

if exist('idConv','var') && ~isempty(idConv)
    neighborIDs = Seg.Local.localGlobalIDConversion(idConv, pCube, ...
        neighborIDs);
end

if nargout > 5
    m = load(pCube.probFile);
    gpProb = m.prob(keepInterfaces);
end


end


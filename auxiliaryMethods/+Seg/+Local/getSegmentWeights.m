function [ weights, weightNames, segIDs ] = getSegmentWeights( pCube, segIDs )
%GETSEGMENTWEIGHTS Get the segment weights for the specified segments.
% INPUT pCube: The parameter struct for the local cube of interest (e.g.
%           p.local(1))
%       segIDs: (Optional) [Nx1] numerical array specifying the global
%           segment IDs of the segments to load.
% OUTPUT weights: [NxM] array of double containing the segment weights.
%           Rows correspond to observations and columns to features.
%        weightNames: Cell array of string containing the names of the
%           features in X.
%        segIDs: [Nx1] array of integer containing the global segment IDs
%           for the corresponding rows in weights.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%get segIDs if necessary

if exist('segIDs','var') && ~isempty(segIDs)
    m = load(pCube.segmentFile);
    cubeSegIDs = [m.segments(:).Id];
    segIdx = ismember(cubeSegIDs,segIDs);
elseif (~exist('segIDs','var') || isempty(segIDs)) && nargout == 3
    m = load(pCube.segmentFile);
    segIDs = [m.segments(:).Id]';
    segIdx = true(length(segIDs),1);
end

m = load(pCube.segmentWeightFile);
weightNames = m.weightNames;

if exist('segIDs','var') && ~isempty(segIDs) %load specified weights
    weights = m.segmentWeights(segIdx,:);
else %load all weights of current cube
    weights = m.segmentWeights;
end

end


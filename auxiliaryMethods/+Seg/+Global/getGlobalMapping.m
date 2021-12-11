function mapping = getGlobalMapping(globalEdges, globalCorrespondences)
%GETGLOBALMAPPING Combine global edge information and inter-cube correspondences
%to create mapping that re-numbers segments to incorporate inter-cube corres-
%pondences
%
%   INPUT
%     globalEdges: [Nx2] array of uint32 containing the edges for the
%         global segment IDs.
%     globalCorrespondences: [Nx2] array of uint32 containing global
%         inter-cube correspondences.
%
%   OUTPUT
%     mapping: [Nx1] array specifying global correspondences mapping.
%
% see getGlobalEdges, getGlobalCorrespondences
%
% NOTE Apply the mapping in the following way
%      globalEdgesInclCorrespondences = mapping(globalEdges);
%
%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%--------------------------------------------------------------------------

% Find connected components in correspondences
[~, objectClassLabels] = Graph.findConnectedComponents(globalCorrespondences);

% Extend objectClassLabels so that max(edgeData(:)) is also included
numObjectsToAdd = max(globalEdges(:)) - length(objectClassLabels);
objectsToAdd = ...
(max(objectClassLabels)+1):(max(objectClassLabels)+numObjectsToAdd);

% Put everything together
mapping = [objectClassLabels objectsToAdd]';

% %renumber IDs
% ids = unique(globalEdges(:));
% idx = false(max(ids(:)),1);
% idx(ids) = true;
% mapping(~idx) = 0;
% [~,~,ic] = unique(mapping(idx));
% reNum = cast(ic,'like',globalEdges);
% mapping(idx) = reNum;

end

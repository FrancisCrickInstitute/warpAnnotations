function [ graph, segmentMeta, borderMeta] = loadGraph( p, getNeighbors, ...
    corrMode )
%LOADGRAPH Load the supervoxel graph from the segmentation main folder.
% INPUT p: struct
%           Segmentation parameter struct. The graph files are loaded from
%           the paths specified in p.svg.
%       getNeighbors: (Optional) logical
%           Flag to calculate the neighbors for the graph.
%           (Default: true)
%       corrMode: (Optional) string
%           Mode how correspondences are handled:
%           'sorted': (default) edge list is sorted (this is also the way
%               it is stored)
%           'end': correspondences are concatenated to the end of the edge
%               list
%           'delete': correspondences are deleted from the edge list
% OUTPUT graph: struct
%           Struct containing the field 'edges', 'borderIdx', 'prob',
%           'synScores'.
%        segmentMeta: struct
%           Struct with segment meta information.
%        borderMeta: struct
%           Struct with border meta information. Border size for
%           correspondences is currently nan. BorderCom for correspondences
%           is loaded from the p.svg.correspondence file or nan if the
%           former does not contain the coms.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('getNeighbors', 'var') || isempty(getNeighbors)
    getNeighbors = true;
end
if ~exist('corrMode', 'var') || isempty(corrMode)
    corrMode = 'sorted';
end

if ~isfield(p, 'svg')
    p = Seg.Util.addSvgFiles(p);
end

graph = load(p.svg.graphFile, 'edges', 'prob', 'borderIdx');
if getNeighbors
    graph = Graph.addNeighbours(graph);
end

% add synapse scores
m = load(p.svg.synScoreFile);
b2gIdx = find(~isnan(graph.borderIdx));
graph.synScores = nan(size(graph.edges));
graph.synScores(b2gIdx(m.edgeIdx), :) = m.synScores;

% get segment meta if required
if nargout > 1
    segmentMeta = load(p.svg.segmentMetaFile, 'voxelCount', 'point');
    segmentMeta.point = segmentMeta.point';
    if exist(p.svg.aggloPredFile, 'file')
        m = load(p.svg.aggloPredFile, 'probs', 'segId');
        segmentMeta.probs = nan(length(segmentMeta.voxelCount), 3);
        segmentMeta.probs(m.segId,:) = m.probs;
    end
    if exist(p.svg.heuristicFile, 'file')
        m = load(p.svg.heuristicFile, 'vesselScore', 'myelinScore', ...
            'nucleiScore');
        segmentMeta.vesselScore = m.vesselScore;
        segmentMeta.myelinScore = m.myelinScore;
        segmentMeta.nucleiScore = m.nucleiScore;
    end
end

% border meta
if nargout > 2
    m = load(p.svg.borderMetaFile, 'borderSize', 'borderCoM');
    borderMeta.borderSize = nan(length(graph.prob), 1);
    borderMeta.borderSize(b2gIdx) = m.borderSize;
    borderMeta.borderCoM = nan(length(graph.prob), 3);
    borderMeta.borderCoM(b2gIdx,:) = m.borderCoM;
    m = load(p.svg.correspondenceFile);
    
    % add border com if it was calculated
    if isfield(m, 'corrCom')
        [~, idx] = sortrows(m.corrEdges);
        % sanity check is sorting is right now
        assert(isequal(graph.edges(isnan(graph.borderIdx), :), ...
            m.corrEdges(idx, :)));
        borderMeta.borderCoM(isnan(graph.borderIdx),:) = m.corrCom(idx,:);
    end
end

switch corrMode
    case 'sorted'
        % nothing to do
    case 'end'
        % get indices of resorting
        idx = b2gIdx;
        idx(end+1:length(graph.prob)) = find(isnan(graph.borderIdx));
        
        graph.edges = graph.edges(idx,:);
        graph.prob = graph.prob(idx);
        graph.borderIdx = graph.borderIdx(idx);
        graph.synScores = graph.synScores(idx, :);
        if nargout > 2
            borderMeta.borderSize = borderMeta.borderSize(idx);
            borderMeta.borderCoM = borderMeta.borderCoM(idx,:);
        end
    case 'delete'
        idx = find(~isnan(graph.borderIdx));
        graph.edges = graph.edges(idx,:);
        graph.prob = graph.prob(idx);
        graph.borderIdx = graph.borderIdx(idx);
        graph.synScores = graph.synScores(idx, :);
        if nargout > 2
            borderMeta.borderSize = borderMeta.borderSize(idx);
            borderMeta.borderCoM = borderMeta.borderCoM(idx,:);
        end
    otherwise
        error('Unknown corrMode ''%s''', corrMode);
end


end


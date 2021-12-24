function [equivalenceClasses, objectClassLabels, notInvolvedNodes] = ...
        findConnectedComponents(sparseAdjMatrixOrEdgeList, keepOnlyAboveSize1, keepOnlyConnectedNodes, nrNodes)
% Finds connected components in undirected graph 
%INPUT: 
% sparseAdjMatrixOrEdgeList:
% either sparse adjanceny matrix (should be symetric, self edges present)
% or undirected edge list (which will be made into symetric adjanceny matrix)
% keepOnlyAboveSize1 = whether to keep only CC with more than 1 element (default=true)
% keepOnlyConnectedNodes = whether to keep only nodes that had edge to begin with (default=false) for edge lists without self-edges parameter 2 is sufficient
% nrNodes = how many nodes there are in total (might be more than captured in edge list)
%OUTPUT:
% first result = cell array with all equivalence classes
% second result = equivalence class label for each object
% third result = nodes that were not considered (due to size 1 and/or not
% connected)
% Author: Manuel Berning <manuel.berning@brain.mpg.de>

if ~exist('keepOnlyAboveSize1', 'var') || isempty(keepOnlyAboveSize1)
    if nargout < 2
        keepOnlyAboveSize1 = true;
    else
        keepOnlyAboveSize1 = false;
    end
end

if nargin < 3
    keepOnlyConnectedNodes = false;
end

% Create sparse undirected adjaceny matrix if not supplied
if ~issparse(sparseAdjMatrixOrEdgeList)
    assert( ...
        size(sparseAdjMatrixOrEdgeList, 2) == 2, ...
        'Edge list must have exactly two columns');
    
    % integer sparse matrices not possible
    edgeList = double(sparseAdjMatrixOrEdgeList);
    nrNodesInEdgeList = max(vertcat(0, max(edgeList(:))));
    
    if ~exist('nrNodes', 'var') || isempty(nrNodes)
        nrNodes = nrNodesInEdgeList;
    else
        assert(nrNodes >= nrNodesInEdgeList);
    end
    
    sparseAdjMatrix = sparse( ...
        cat(1, edgeList(:, 1), edgeList(:, 2)), ...
        cat(1, edgeList(:, 2), edgeList(:, 1)), ...
        1, nrNodes, nrNodes);
else
    sparseAdjMatrix = sparseAdjMatrixOrEdgeList;
end
% Save memory
clear sparseAdjMatrixOrEdgeList;

% Check whether adjMatrix is symetric
if ~issymmetric(sparseAdjMatrix)
    error('supplied sparse matrix not symetric');
end

% Find block diagonal matrix permutation (other row and column perumtation different)
[rowPermutation,~,rowBlockBoundaries] = dmperm(sparseAdjMatrix + speye(size(sparseAdjMatrix)));

% Create vector with one at each rowBlockBoundaries (start of block)
newLabelStart = zeros(1,size(sparseAdjMatrix,1));
newLabelStart(rowBlockBoundaries(1:end-1)) = 1;

% Calculate object class labels (equivalence class of each object)
objectClassLabels = cumsum(newLabelStart);
objectClassLabels(rowPermutation) = objectClassLabels;

% Keep only elements in equivalence-classes that have at least one edge in original graph
if keepOnlyConnectedNodes
    mask = ~any(sparseAdjMatrix(rowPermutation,rowPermutation),1);
    notInvolvedNodes = rowPermutation(mask)';
    rowPermutation(mask) = [];
    newLabelStart(mask) = [];
    rowBlockBoundaries = [find(newLabelStart) length(newLabelStart)+1];
else
    notInvolvedNodes = [];
end

% Create cell array of equivalence classes
sizeBlocks = diff(rowBlockBoundaries);
if keepOnlyAboveSize1
    sizeBlocks(sizeBlocks == 1) = [];
    notInvolvedNodes = cat(1,notInvolvedNodes,rowPermutation(~(newLabelStart == 0 | [diff(newLabelStart) 0] == -1))');
    rowPermutation(~(newLabelStart == 0 | [diff(newLabelStart) 0] == -1)) = [];
end
equivalenceClasses = mat2cell(rowPermutation', sizeBlocks);
notInvolvedNodes = unique(notInvolvedNodes);

% relabel objectClassLabels (LUT) by updating the equivalence class and
% making refs to deleted equivalence Classes NaN
numNodes = cellfun(@numel,equivalenceClasses);
objectClassLabels(cell2mat(equivalenceClasses)) = repelem(1:numel(equivalenceClasses),numNodes);
objectClassLabels(notInvolvedNodes) = NaN;
end


function [X, fm] = getInterfaceFeatures(p, edgeIdx, areaT, invertDir, ...
    featureFile, fm)
%GETINTERFACEFEATURES Load precomputed interface features for the
% specified edges.
% INPUT p: struct
%          Segmentation parameter struct.
%       edgeIdx: [Nx1] int
%           Linear interfaces of the edges of interest.
%       areaT: (Optional) int
%           Area threshold below which the interface in the local
%           segmentation cube were calculated. Interfaces features for
%           interface below the threshold contain Nan in the outputs. Only
%           use this if the default does not apply.
%           (Default: areaT variable in p.local.interfaceFeatureFile or
%               fm.areaT from p.synEM if the former does not exist)
%       invertDir: (Optional) logical
%           Flag to return the features for both directions of an
%           interface. If true then size(X, 1) is 2*length(edgeIdx) where
%           the first half of the edges corresponds to the first direction
%           of the corresponding edges and the second half to the inverted
%           direction.
%           (Default: true if fm.mode == 'direction')
%       featureFile: (Optional) string
%           String specifying the name of the feature file in each local
%           segmentation cube.
%           (Default: 'InterfaceFeatures.mat')
%       fm: (Optional) SynEM.FeatureMap object or string
%           The feature map or string to the file in the segmentation main
%           folder where the feature map is stored (with variable name
%           'fm').
%           (Default: 'SynapseClassifier.mat')
% OUTPUT X: [MxN] single
%           Interface features for the respective edge.
%        fm: SynEM.Feature map object
%           Feature map used to calculate the feature matrix X.
%
% NOTE This function requires to run Seg.Global.saveGlobalSvgData first
%      with default names.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

edgeIdx = edgeIdx(:);

m = load([p.saveFolder 'maxEdgeIdxForCube.mat']);
maxEdgeIdx = m.maxEdgeIdx;

% feature map
if ~exist('fm', 'var') || isempty(fm)
    m = load([p.saveFolder 'SynapseClassifier'], 'fm');
    fm = m.fm;
elseif ischar(fm)
    m = load([p.saveFolder fm], 'fm');
    fm = m.fm;
end

if ~exist('invertDir', 'var') || isempty(invertDir)
    invertDir = strcmp(fm.mode, 'direction');
end

if ~exist('featureFile', 'var') || isempty(featureFile)
    featureFile = 'InterfaceFeatures.mat';
end

%area threshold default (search in file first, otherwise use fm)
if ~exist('areaT', 'var') || isempty(areaT)
    
    % try to load the interfaceFeatureFile
    try
        warning('off', 'all') % do not warn if areaT is not in the file
        m = load(p.local(1).interfaceFeatureFile, 'areaT');
        warning('on', 'all')
    catch
        m = [];
    end
    
    if isfield(m, 'areaT')
        areaT = m.areaT;
    else
        areaT = fm.areaT;
    end
end

m = load([p.saveFolder 'globalBorder.mat'], 'borderSize');
borderSize = m.borderSize;

X = nan(length(edgeIdx), fm.getNumFeatures(), 'single');
smallEdges = ~(borderSize(edgeIdx) > areaT);
isDone = smallEdges;
maxEdgeIdx = [0; maxEdgeIdx];
for i = 2:length(maxEdgeIdx)
    edgeInCurCube = edgeIdx > maxEdgeIdx(i-1) & ...
                    edgeIdx <= maxEdgeIdx(i) & ...
                    ~smallEdges;
    if any(edgeInCurCube)
        %convert global edge idx to local edge idx
        g2lIdx = cast(borderSize(maxEdgeIdx(i-1)+1:maxEdgeIdx(i)) > ...
            areaT, 'uint32');
        g2lIdx(g2lIdx > 0) = 1:sum(g2lIdx > 0);
        curEdges = g2lIdx(edgeIdx(edgeInCurCube) - maxEdgeIdx(i-1));

        %load features
        m = load([p.local(i-1).saveFolder featureFile]);
        X(edgeInCurCube, :) = m.X(curEdges,:);
    end

    isDone = isDone | edgeInCurCube;
    if all(isDone) %early stopping
        break;
    end
end

if invertDir
    X = [X; fm.invertDirection(X)];
else

end


end

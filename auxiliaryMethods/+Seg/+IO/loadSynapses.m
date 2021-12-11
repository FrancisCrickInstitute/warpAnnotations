function [ synCom, synScores, edgeIdx ] = loadSynapses( p, t )
%LOADSYNAPSES Very basic function to load the synapse predictions
% from the global segmentation data.
% This assumes that 'globalBorder.mat' and 'globalSynScores.mat'
% exists in the segmentation main folder (e.g. saved by
% Seg.Global.saveGlobalSvgData in the pipeline).
% INPUT p: struct
%           Segmentation parameter struct.
%       t: double
%           The threshold for synapse detection. The output will be sorted
%           by decreasing threshold (i.e. from more likely to less likely
%           synapses. To determine a good threshold you can thus start
%           looking at the predictions until you reach a point with many FP
%           detection. This can be at a much lower threshold than the
%           default value of -1.67).
%           (Default: -1.67)
% OUTPUT synCom: [Nx3] int
%           The global center of mass (com) of the predicted synapses.
%           Synapses will be sorted with decreasing score (i.e. more likely
%           synapses to less likely ones).
%       synScores: [Nx1] double
%           The scores of the predicted synapses (maximum over both
%           directions).
%       edgeIdx: [Nx1] int
%           The linear index of the global edge list for the corresponding
%           synapse predictions.
%
% NOTE Since the synapse classifier was not trained in somata and blood
%      vessels there can be many false positive detections there. This is
%      expected and requires a blood vessel/soma masking to discard those
%      FPs.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('t', 'var') || isempty(t)
    t = -1.67;
end

% get the global border coms
m = load(fullfile(p.saveFolder, 'globalBorder.mat'), 'borderCoM');
borderCom = m.borderCoM;

% get the global synapse scores
m = load(fullfile(p.saveFolder, 'globalSynapseScores.mat'));
borderCom = borderCom(m.edgeIdx,:); % only keep borders above area threshold
synScores = max(m.synScores, [], 2); % maximum over both interface directions

% get the predicted synapses
idx = synScores > t;
synCom = borderCom(idx, :);
synScores = synScores(idx);

% get the corresponding edges
edgeIdx = m.edgeIdx(idx);

% sort everything according to synScores (descending)
[synScores, sI] = sort(synScores, 'descend');
synCom = synCom(sI, :);
edgeIdx = edgeIdx(sI);

end


function saveGlobalSvgData( p, options, forceRecalc, doPhysicalBorders)
%SAVEGLOBALSVGDATA Wrapper function to calculate global svg information.
% INPUT p: Segmentation parameter struct. Files are saved in the
%           segmentation save folder. See below for names of save files.
%       options: (Optional) Structure to change output filenames. The file
%           names for the following outputs can be specified:
%           'edgeFile'
%           'mappingFile'
%           'maxEdgeIdx'
%           'ncProbFile'
%           'borderFile'
%           'synFile'
%       forceRecalc: (Optional) logical
%           Flag indicating whether outputs that already exists should be
%           recalculated.
%           (Default: false)
%       dophysicalborders: (optional) logical
%           Flag indicating whether physical borders should be calculated
%           (Default: true)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

info = Util.runInfo(false);

if ~exist('forceRecalc', 'var') || isempty(forceRecalc)
    forceRecalc = false;
end
if nargin < 4 || isempty(doPhysicalBorders)
    doPhysicalBorders = false;
end

% set default output files
optDef = defaultOptions();
if exist('options','var') && ~isempty(options)
    options = Util.setUserOptions(optDef, options);
else
    options = optDef;
end

% edges
Util.log('Loading global edge list.');
if ~exist([p.saveFolder, options.edgeFile], 'file') || forceRecalc
    [edges, maxEdgeIdx] = Seg.Global.getGlobalEdges(p);
    Util.save([p.saveFolder, options.edgeFile], edges, maxEdgeIdx, info);
    Util.save([p.saveFolder, options.maxEdgeIdx], maxEdgeIdx);
    clear edges maxEdgeIdx
end

% segment continuity score
Util.log('Loading neurite continuity probabilities.');
if ~exist([p.saveFolder, options.ncProbFile], 'file') || forceRecalc
    try %if was calculated already
        prob = Seg.Global.getGlobalGPProbList( p );
        if ~isempty(prob)
            Util.save([p.saveFolder, options.ncProbFile], prob, info);
        end
        clear prob
    catch err
        warning('Global continuity score loading errored: %s', ...
            err.message);
    end
end

% correspondence mapping
Util.log('Loading correspondences.');
if ~exist([p.saveFolder, options.corrFile], 'file') || forceRecalc
    % Needed in case of %edges block already calculated before
    try
        % load correspondences
        m = load(fullfile(p.saveFolder, options.edgeFile), 'edges');
        edges = m.edges;
        
        [correspondences, corrCom] = ...
            connectEM.collectGlobalCorrespondences(p);
        tmp.corrEdges = correspondences;
        tmp.corrComs = corrCom;
        tmp.info = info;
        
        % correspondence file
        Util.saveStruct(fullfile(p.saveFolder, options.corrFile), tmp);
        
        % correspondence mapping
        mapping = Seg.Global.getGlobalMapping(edges, correspondences);
        Util.save(fullfile(p.saveFolder, options.mappingFile), mapping, ...
            correspondences, info);
        clear m mapping correspondences edges tmp corrCom m
    catch err
        warning('Could not load correspondences: %s.', err.message);
    end
end

% border meta
Util.log('Calculating border metadata.');
if ~exist([p.saveFolder, options.borderFile], 'file') || forceRecalc
    borderMeta = Seg.Global.borderMeta(p, ~doPhysicalBorders);
    borderMeta.info = info;
    Util.saveStruct(fullfile(p.saveFolder, options.borderFile), borderMeta);
    clear borderMeta
end

% synapse score
Util.log('Loading synapse scores.');
if ~exist([p.saveFolder, options.synFile], 'file') || forceRecalc
    try %if was calculated already
        [synScores, edgeIdx] = Seg.Global.getGlobalSynapsePrediction(p);
        Util.save([p.saveFolder, options.synFile], synScores, edgeIdx, ...
            info);
        clear synScores edgeIdx
    catch err
        warning('Synapse score loading errored: %s', err.message);
    end
end

Util.log('Finished global svg data loading.');

end

function defOpts = defaultOptions()
defOpts.edgeFile = 'globalEdges.mat';
defOpts.maxEdgeIdx = 'maxEdgeIdxForCube.mat';
defOpts.corrFile = 'correspondences.mat';
defOpts.mappingFile = 'mapping.mat';
defOpts.ncProbFile = 'globalNeuriteContinuityProb.mat';
defOpts.borderFile = 'globalBorder.mat';
defOpts.synFile = 'globalSynapseScores.mat';
end

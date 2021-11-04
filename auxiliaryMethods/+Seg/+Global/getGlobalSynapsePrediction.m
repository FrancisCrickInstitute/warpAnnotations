function [ pred, edgeIdx ] = getGlobalSynapsePrediction( p, mode, noBorders )
%GETGLOBALSYNAPSEPREDICTION Load the global synapse predictions.
% INPUT p: struct
%           Segmentation parameter struct.
%       mode: (Optional) String
%           'full': The outputs are with respect to all edges in the local
%               segmentation cube. If an edge size is below the area
%               threshold than the corresponding row in synScores contains
%               NaNs.
%           'valid': (Default) Only edges above the area threshold are
%               considered and other edges are removed from all output
%               variables.
%       noBorders: (Optional) logical
%           Flag that indicate that borders should not be loaded (only for
%           'valid' mode) which increases speed of this function.
%           (Default: false)
% OUTPUT pred: [Nx2] single
%           Synapse prediction scores for edges. The first column
%           corresponds for the pred of the synapse direction from first to
%           second column in the edge list and the second column for the
%           inverse direction. If an edge is below the area threshold for
%           interface classification then pred will contain NaNs in that
%           row (see 'full' mode) or the corresponding row is deleted (see
%           'valid' mode).
%        edgesIdx: [Nx1] int
%           Linear index of the global edge list for the respective row in
%           pred.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('mode','var') || isempty(mode)
    mode = 'valid';
end

if ~exist('noBorders', 'var') || isempty(noBorders) || ~noBorders
    noBorders = false;
    edgeIdx = cell(numel(p.local),1);
else
    idx = [];
    edgeIdx =  [];
end

pred = cell(numel(p.local),1);


count = 0; % to globalize the local edge indices
Util.log('Loading synapse scores.');
fprintf('Progress:  0%%');
for i = 1:numel(p.local)
    
    if ~exist(p.local(i).synapseFile, 'file')
        warning('Synapse file %s does not exist.', p.local(i).synapseFile);
        continue;
    end
    
    %load border scores
    m = load(p.local(i).synapseFile);
    scores = m.scores;
    
    if ~isfield(p, 'edgeIdx') && ~noBorders
        m = load(p.local(i).borderFile);
        idx = [m.borders.Area] > 150;
    elseif isfield(p, 'edgeIdx')
        idx = m.edgeIdx;
    end

    switch mode
        case 'full'
            pred{i} = nan(length(idx), 2, 'like', scores);
            pred{i}(idx,:) = scores;
        case 'valid'
            pred{i} = scores;
            if ~noBorders
                edgeIdx{i} = find(idx) + count;
                if isrow(edgeIdx{i})
                    edgeIdx{i} = edgeIdx{i}';
                end
            end
        otherwise
            error('Unknown mode %s.', mode);
    end
    count = count + length(idx);
    if floor(i/numel(p.local)*100) < 10
        fprintf('\b\b%d%%',floor(i/numel(p.local)*100));
    else
        fprintf('\b\b\b%d%%',floor(i/numel(p.local)*100));
    end
end
fprintf('\n');
Util.log('Finished loading of synapse scores.');

pred = cell2mat(pred);

switch mode
    case 'full'
        if nargout > 1
            edgeIdx = (1:size(pred,1))';
        end
    case 'valid'
        if ~noBorders
            edgeIdx = cell2mat(edgeIdx);
        end
end

end

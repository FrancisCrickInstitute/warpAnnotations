function isoSurfs = buildIsoSurfaceOfAgglo(param, agglo, varargin)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % default output directory
    outputDir = tempname(Util.getTempDir());
    
    % override by user-specified outputDir, if present
    outputDirIdx = find(strcmpi(varargin, 'outputDir'));
    
    if ~isempty(outputDirIdx)
        assert(isscalar(outputDirIdx));
        outputDir = varargin{outputDirIdx + 1};
        varargin((0:1) + outputDirIdx) = [];
    end
    if ~iscell(agglo{1})
        agglo = {agglo};
    end
    inputs = {};
    for a = 1:numel(agglo)
        if iscell(outputDir)
            assert(numel(outputDir)==numel(agglo))
            thisOutputDir = outputDir{a};
        else
            thisOutputDir = outputDir;
        end
        % create output directory
        mkdir(thisOutputDir);
        
        outFiles = arrayfun(@(idx) ...
            fullfile(thisOutputDir, sprintf('iso-%d.mat', idx)), ...
            1:numel(agglo{a}), 'UniformOutput', false);
        inputs = cat(1,inputs,cellfun(@(segIds, outFile) ...
            {{segIds, outFile}}, agglo{a}(:), outFiles(:)));
    end
    job = Cluster.startJob( ...
        @jobMain, inputs, ...
        'sharedInputs', cat(2, {param}, varargin), ...
        'sharedInputsLocation', [1, 3 + (1:numel(varargin))], ...
        'cluster', { ...
            'memory', 12, ...
            'priority', 99, ...
            'time', '4:00:00', ...
            'taskConcurrency', 40}, ...
        'name', mfilename());
    wait(job);
    
    % we're done
    if nargout < 1; return; end
    
    % load and return isosurfaces
    Util.log('Fetching calculated iso surfaces')
    isoSurfs = cellfun(@load, outFiles(:), 'UniformOutput', false);
end

function jobMain(param, segIds, outFile, varargin)
    info = Util.runInfo();
    isoSurf = Visualization.buildIsoSurface(param, segIds, varargin{:});
    Util.save(outFile, info, isoSurf);
end

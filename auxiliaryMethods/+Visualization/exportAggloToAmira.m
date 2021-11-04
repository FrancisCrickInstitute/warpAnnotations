function exportAggloToAmira(param, agglos, outDir, varargin)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~iscell(agglos)
        agglos = {agglos};
    end
    
    matDir = fullfile(outDir, 'mat');
    plyDir = fullfile(outDir, 'ply');
    if ~iscell(matDir)
        matDir = {matDir};
        plyDir = {plyDir};
    end
    
    % calculate isosurfaces
    Util.log('Generating isosurfaces');
    Visualization.buildIsoSurfaceOfAgglo( ...
        param, agglos, varargin{:}, 'outputDir', matDir);
    
    % find MAT files with isosurfaces
    allInFiles = cellfun(@dir,fullfile(matDir, 'iso-*.mat'),'uni',0);
    cellfun(@mkdir,plyDir);

    Util.log('Generating PLY files');
    tic;
    for f = 1:numel(allInFiles)
        inFiles = allInFiles{f};
        for curIdx = 1:numel(inFiles)
            curInFile = inFiles(curIdx);
            curInFile = fullfile(matDir{f}, curInFile.name);
            
            % generate name of output file
            [~, curOutFile] = fileparts(curInFile);
            curOutFile = fullfile(plyDir{f}, strcat(curOutFile, '.ply'));
            
            curIso = load(curInFile, 'isoSurf');
            curIso = curIso.isoSurf;
            
            Visualization.exportIsoSurfaceToAmira(param, curIso, curOutFile);
            Util.progressBar(curIdx, numel(inFiles));
        end
    end

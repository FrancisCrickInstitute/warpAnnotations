function exportNmlToAmira(param, nmlFile, outDir, varargin)
    % exportNmlToAmira(param, nmlFile, outDir)
    %   This function allows you to render each tree in a
    %   given NML file (`nmlFile`) as separate isosurface and
    %   to export it to Amira. For each tree, a separate PLY
    %   file is generated and written to `outDir`.
    %
    %   All supplementary input arguments are forwarded to
    %   the `buildIsoSurfaceOfSkel` function. Have a look at
    %   its documentation for further information.
    %
    % Example
    %   Visualization.exportNmlToAmira( ...
    %     p, '/gaba/u/amotta/input.nml', ...
    %     '/gaba/u/amotta/output-dir');
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    % Modified by
    %   Sahil Loomba <sahil.loomba@brain.mpg.de> 
  
    % create output directory
    if ~exist(outDir, 'dir')
        mkdir(outDir);                                                                                                                                                       
    end
 
    % build iso-surfaces
    [isoSurfs,emptyTrees] = ...
        Visualization.buildIsoSurfaceOfSkel(param, nmlFile, varargin{:});

    optIn = struct;
    optIn.treeNames = false;
    optIn = Util.modifyStruct(optIn, varargin{:});
    if optIn.treeNames
        skel = skeleton(nmlFile);
        treeNames = skel.names; 
        outFiles = cellfun(@(name) ...
            sprintf('iso-%s.ply', name), ...
            treeNames, 'UniformOutput', false);
        outFiles = outFiles(~emptyTrees);
    else
        outFiles = arrayfun(@(idx) ...
            sprintf('iso-%d.ply', idx), ...
            1:numel(isoSurfs), 'UniformOutput', false);
    end
    outFiles = fullfile(outDir, outFiles);
    
    Visualization.exportIsoSurfaceToAmira(param, isoSurfs, outFiles);
end

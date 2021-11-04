function maxSegId = getMaxSegId(param)
    % maxSegId = getMaxSegId(param)
    %   Finds the highest global segment ID occuring in a
    %   given dataset.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    rootDir = param.saveFolder;
    metaFile = fullfile(rootDir, 'segmentMeta.mat');
    
    if ~exist(metaFile, 'file')
        % for backward compatibility
        % TODO: remove as soon as possible
        graph = load(fullfile(rootDir, 'graph.mat'), 'edges');
        maxSegId = max(graph.edges(:));
        return;
    end
    
    % load maximum segment ID and convert it to
    % a double (for backward compatibility)
    meta = load(metaFile, 'maxSegId');
    maxSegId = double(meta.maxSegId); 
end
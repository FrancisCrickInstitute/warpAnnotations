function isAbove = isMaxBorderToBorderDistAbove(param, minDistNm, agglos)
    % isAbove = isMaxBorderToBorderDistAbove(param, minDistNm, agglos)
    %
    % INPUT
    % param        pipeline parameter structure
    % minDistNm    minimum distance in nm that is checked
    % agglos       agglos in old representation
    % graph        (optional) graph structure containin borderIdx and edges
    %
    % OUTPUT
    % isAbove       boolean vector of which agglos are above minDistNm
    %               length
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    %% load data
    rootDir = param.saveFolder;
    
    % prepare graph
    graph = loadGraph(rootDir);
    graph(~graph.borderIdx, :) = [];
    
    % find border for each agglo
    maxSegId = Seg.Global.getMaxSegId(param);
    aggloLUT = Agglo.buildLUT(maxSegId, agglos);
    
    graph.aggloIds = aggloLUT(graph.edges);
    graph(~diff(graph.aggloIds, 1, 2), :) = [];
    
    % group borders by agglomerate
    aggloBorderIds = accumarray( ...
        1 + graph.aggloIds(:), repmat(graph.borderIdx, 2, 1), ...
        [], @(borderIds) {borderIds});
    aggloBorderIds(1) = [];
    
    % load border CoM
    borderFile = fullfile(rootDir, 'globalBorder.mat');
    load(borderFile, 'borderCoM');
    
    % to physical units
    borderCoM = double(borderCoM); %#ok
    borderCoM = bsxfun(@times, borderCoM, param.raw.voxelSize);
    
    isAboveFunc = @(b) Util.isMaxPdistAbove(borderCoM(b, :), minDistNm);
    isAbove = cellfun(isAboveFunc, aggloBorderIds);
end

function graph = loadGraph(rootDir)
    % NOTE(amotta): This is a copy of +Graph/load.m from commit
    % 378148ca282b6db77a89d4e838da28bb10a864f2 of the amotta repository.
    graphFile = fullfile(rootDir, 'graph.mat');
    graph = load(graphFile, 'edges', 'prob', 'borderIdx');
    
    % NOTE(amotta): Use border idx zero instead of nan
    graph.borderIdx(isnan(graph.borderIdx)) = 0;
    
    % make table (more convenient)
    graph = struct2table(graph);
end

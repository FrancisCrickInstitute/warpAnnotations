function [agglos, probs] = getGliaAgglos(param, varargin)
    % GETGLIAAGGLOS
    %   Get all glia agglomerates in a data set.
    %
    % param
    %   Parameter struct for data set.
    %
    % agglos
    %   Cell array. Each entry corresponds to a glia agglo-
    %   merate and contains a list of global segment s.
    %
    % additional input arguments (optional)
    %   See Seg.Local.getGliaAgglos for a complete list
    %   of additional input arguments.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    cubes = param.local;
    cubeCount = numel(cubes);
    
    % prepare output
    agglos = cell(cubeCount, 1);
    probs = cell(cubeCount, 1);
    
    % for progress
    tic;
    
    % iterate over cubes
    for curIdx = 1:cubeCount
        [agglos{curIdx}, probs{curIdx}] = ...
            Seg.Local.getGliaAgglos(cubes(curIdx), varargin{:});
        
        % show progress
        Util.progressBar(curIdx, cubeCount);
    end
    
    % fuse together
    agglos = vertcat(agglos{:});
    probs = vertcat(probs{:});
end

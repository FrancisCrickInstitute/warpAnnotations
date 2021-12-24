function [agglos, probs] = getGliaAgglos(cube, minGliaProb)
    % GETGLIAAGGLOS
    %   Get all glia agglomerates in a cube.
    %
    % cube
    %   Parameter struct for cube of interest.
    %
    % agglos
    %   Cell array. Each entry corresponds to a glia agglo-
    %   merate and contains a list of global segment ids.
    %
    % minGliaProb (optional)
    %   Scalar. Minimal prediction score required for a
    %   segment to be considered glial.
    %
    %   If 'minGliaProb' is not specified, you'll be served
    %   what is considered best by your local glia expert.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    cubeDir = cube.saveFolder;
    
    % load glia probabilities
    predFile = [cubeDir, 'aggloPreds.mat'];
    preds = load(predFile, 'gliaProbs');
    gliaProbs = preds.gliaProbs;
    
    if exist('minGliaProb', 'var')
        % build mask
        aggloMask = (gliaProbs >= minGliaProb);
    else
        % load glia mask
        gliaFile = [cubeDir, 'glia.mat'];
        glia = load(gliaFile, 'aggloMask');
        aggloMask = glia.aggloMask;
    end
    
    % load agglomerates
    aggloFile = [cubeDir, 'agglos.mat'];
    aggloStruct = load(aggloFile, 'agglos');
    
    % filter agglomerates
    agglos = aggloStruct.agglos(aggloMask);
    probs = gliaProbs(aggloMask);
    
    % unpack segment ids
    agglos = cellfun(@(a) {a.segIds}, agglos);
end

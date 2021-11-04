function [massesOut, comVecsOut, covMatsOut] = ...
        mergeStatisticalMoments(massesIn, comVecsIn, covMatsIn, agglos)
    % mergeStatisticalMoments(massesIn, comVecsIn, covMatsIn, agglos)
    %   Merges the statistical moments of individual segments.
    %
    % General idea
    %   Convert the covariance matrix into an inertia tensor. Use the
    %   Huygens-Steiner theorem (i.e., the parallel axis theorem) to merge
    %   mass properties and then convert back to the statistical
    %   interpretation.
    %
    % Note
    %   This whole function is way too complicated. The combination of
    %   statistical moments could easily be done without conversion to /
    %   from the inertia tensor. But it seems to work
    %
    % masses{In, Out}
    %   Nx1 vector with the volume per segment.
    %
    % comVecs{In, Out}
    %   Nx3 matrix with the center of mass per segment.
    %
    % covMats{In, Out}
    %   Nx3x3 matrix with the covariance matrix per segment.
    %
    % agglos
    %   Mx1 cell array. Each cell contains a set of segment IDs.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % build inertia matrices
    segCountIn = numel(massesIn);
    inMatsIn = nan(segCountIn, 3, 3);
    
    for curIdx = 1:segCountIn
        inMatsIn(curIdx, :, :) = covarianceToInertiaMatrix( ...
            massesIn(curIdx), squeeze(covMatsIn(curIdx, :, :)));
    end
    
    coreFunctionClosure = @(segIds) coreFunction( ...
        massesIn(segIds), comVecsIn(segIds, :), inMatsIn(segIds, :, :));
    [massesOut, comVecsOut, covMatsOut] = cellfun( ...
        coreFunctionClosure, agglos(:), 'UniformOutput', false);
    
    % build output
    massesOut = cell2mat(massesOut);
    comVecsOut = cell2mat(comVecsOut);
    covMatsOut = cell2mat(covMatsOut);
end

function [massOut, comVecOut, covMatOut] = ...
        coreFunction(massesIn, comVecsIn, inMatsIn)
    % Based on matlab/+Mask/massProperties.m
    % From https://gitlab.mpcdf.mpg.de/connectomics/amotta
    
    % calculate mass
    massOut = sum(massesIn);
    
    % calculate center of mass
    comVecOut = bsxfun(@times, massesIn, comVecsIn);
    comVecOut = sum(comVecOut, 1) ./ massOut;
    
    % calculate displacements
    dispVecs = bsxfun(@minus, comVecsIn, comVecOut);
    
    % compute R ⊗ R
    outerProdMat = repmat(dispVecs, [1, 1, 3]);
    outerProdMat = outerProdMat .* permute(outerProdMat, [1, 3, 2]);
    
    % compute R • R
    dotProdMat =  dot(dispVecs, dispVecs, 2);
    
    % compute (R • R) E_3
    dotProdMat =  bsxfun(@times, dotProdMat, reshape(eye(3), [1, 3, 3]));
    
    % compute (R • R) E_3 - R ⊗ R
    centOffMat = -bsxfun(@minus, outerProdMat, dotProdMat);
    
    % compute M((R • R) E_3 - R ⊗ R)
    inMatOut = bsxfun(@times, centOffMat, massesIn);
    
    % compute I + M((R • R) E_3 - R ⊗ R) 
    inMatOut = bsxfun(@plus, inMatsIn, inMatOut);
    
    % finally, sum up everything
    inMatOut = squeeze(sum(inMatOut, 1));
    
    % build covariance matrix
    covMatOut = inertiaToCovarianceMatrix(massOut, inMatOut);
    covMatOut = reshape(covMatOut, 1, 3, 3);
end

function inMat = covarianceToInertiaMatrix(mass, covMat)
    covMat = mass * covMat;
    inMat = eye(size(covMat)) * trace(covMat) - covMat;
end

function covMat = inertiaToCovarianceMatrix(mass, inMat)
    covMat = eye(size(inMat)) * trace(inMat) - 2 * inMat;
    covMat = covMat / (2 * mass);
end

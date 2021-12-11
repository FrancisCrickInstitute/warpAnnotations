function [segIds, coms, diams] = calculateDiameter( ...
        segSizes, segCentroids, segCov, agglos, varargin)
    % [segIds, coms, diams] = calculateDiameter( ...
    %     segSizes, segCentroids, segCov, agglos, varargin)
    %   Calculates a diameter estimate for most segments in an agglomerate.
    %   It does so by building a local neighbourhood around each segment
    %   based on a distance threshold.
    %
    %   Within each neighbourhood an ellipsoid is fitted to the inertia
    %   matrix. The geometric mean of the two smaller half axes is used as
    %   an estimate of the local radius.
    %
    % Input arguments
    %   segSizes
    %     Nx1 vector with segment masses (i.e., voxel count).
    %
    %   segCentroids
    %     Nx3 matrix with the centroid of each segment. This values should
    %     be in nm.
    %
    %   segCov
    %     Nx3x3 matrix with the covariance matrix of each segment. The
    %     values should be in nm².
    %
    %   agglos
    %     Cell array of segment equivalence classes.
    %
    % Optional input arguments
    %   nhoodThresh
    %     Positive real number. All segments whose centroid is less than
    %     `nhoodThresh` nm are considered to be in the local neighbourhood.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    opts = struct;
    opts.nhoodThresh = 750;
    opts = Util.modifyStruct(opts, varargin{:});
    
   [segIds, coms, diams] = cellfun( ...
        @forAgglo, agglos, 'UniformOutput', false);

    function [segIds, comVecs, diams] = forAgglo(segIds)
        segIds = reshape(segIds, [], 1);
        
        % NOTE(amotta): It's possible that the segment covariance matrix is
        % in some way degenerate (e.g., `nan` or `inf` for tiny segments).
        % Let's remove these segments.
        segMask = reshape(segCov(segIds, :, :), numel(segIds), []);
        segMask = not(any(isinf(segMask) | isnan(segMask), 2));
        segIds = segIds(segMask);
        
        % Build neighbourhoods
        segToSegDist = fixedSquareform(pdist(segCentroids(segIds, :)));
        segToSegDist = segToSegDist <= opts.nhoodThresh;

        nhoods = nan(sum(segToSegDist(:)), 2);
       [nhoods(:, 1), nhoods(:, 2)] = find(segToSegDist);

        nhoods = accumarray( ...
            nhoods(:, 1), nhoods(:, 2), ...
           [size(segToSegDist, 1), 1], @(ids) {ids});
       
        % Build statistical moments for each neighbourhood
       [massesOut, comVecs, covMatsOut] = ...
            Agglo.mergeStatisticalMoments( ...
                segSizes(segIds), segCentroids(segIds, :), ...
                segCov(segIds, :, :), nhoods);
            
        % Convert covariance matrix into inertia tensor
        % I = E_3 * tr(C) - C, with E being the identity matrix
        covMatsOut = massesOut .* covMatsOut;
        covMatsOut = reshape(covMatsOut, [], 9);
        
        % calculate C - E_3 * tr(C)
        covMatsOut(:, 1:(3 + 1):9) = ...
            covMatsOut(:, 1:(3 + 1):9) ...
          - sum(covMatsOut(:, 1:(3 + 1):9), 2);
        
        % calculate inertia tensor
        covMatsOut = -covMatsOut;
        covMatsOut = reshape(covMatsOut, [], 3, 3);
        
        diams = nan(size(segIds));
        for curIdx = 1:numel(segIds)
            curMass = massesOut(curIdx);
            curInMat = shiftdim(covMatsOut(curIdx, :, :));
            
            % extract half-axes of ellipsoid from tensor of inertia
           [~, curDiag] = eig(curInMat, 'vector');
            curHalfAxes = sqrt(5 * (sum(curDiag) / 2 - curDiag) / curMass);
            diams(curIdx) = 2 * sqrt(prod(curHalfAxes(2:3)));
        end
    end
end

function out = fixedSquareform(pdists)
    if isempty(pdists)
        % Stupid MATLAB...
        out = zeros(1);
    else
        out = squareform(pdists);
    end
end
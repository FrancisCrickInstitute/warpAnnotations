function [pcaMat, covMat] = segmentPCA( segPixelIdx, cubeSize, voxelSize, ...
    lowerSegSize, sampleN )
%SEGMENTPCA Principal components for a segment.
% INPUT segPixelIdx: [Nx1] cell
%           Cell array of linear pixel indices for each segment.
%       cubesize: [1x3] int
%           Size of the local segmentation cube in voxel.
%       voxelSize: [1x3] double
%           Voxel size for each dimension.
%       lowerSegSize: (Optional) int
%           Only segments with size bigger equal to lowerSegSize are
%           considered.
%           (Default: 0)
%       sampleN: (Optional) int
%           For each segment the PCA is calculated on a set of N sample
%           points.
%           (Default: all points)
% OUTPUT pcaMat: [Nx12] double
%           PCA data for each segment where
%           * values 1 to 9 correspond to the pca coefficients, and
%           * values 10 to 12 contain the latent scores.
%        covMat: [Nx9] double
%           Sample covariance matrix.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

cubeSize = cubeSize(:)';
voxelSize = voxelSize(:)';
segPixelIdx = segPixelIdx(:);

% seg size threshold
if exist('lowerSegSize', 'var') && ~isempty(lowerSegSize)
    idx = cellfun(@length, segPixelIdx) >= lowerSegSize;
    segPixelIdx = segPixelIdx(idx);
else
    idx = true(length(segPixelIdx), 1);
end

% sample points
if exist('sampleN', 'var') && ~isempty(sampleN)
    segPixelIdx = cellfun(@(x)samplePoints(x, sampleN), segPixelIdx, ...
        'UniformOutput', false);
end

segPixelIdx = cellfun(@(x)Util.indToSubMat(cubeSize, x), ...
    segPixelIdx, 'UniformOutput', false);
segPixelIdx = cellfun(@(x)bsxfun(@times, x, voxelSize), segPixelIdx, ...
    'UniformOutput', false);
[coeff, ~, latent] = cellfun(@pca, segPixelIdx, 'UniformOutput', false);



% replace missing values with nan
for i = 1:length(coeff)
    coeff{i} = coeff{i}(:)';
    coeff{i}(end+1:9) = NaN;
    latent{i} = latent{i}(:)';
    latent{i}(end+1:3) = NaN;
end

pcaMat = nan(length(idx), 12);
pcaMat(idx, :) = cat(2, cell2mat(coeff), cell2mat(latent));

if nargout == 2
    C = cellfun(@cov, segPixelIdx, 'UniformOutput', false);
    for i = 1:length(C)
        C{i} = C{i}(:)';
        C{i}(end+1:9) = NaN;
    end
    covMat = nan(length(C), 9);
    covMat(idx, :) = cell2mat(C);
end

end

function s_idx = samplePoints(idx, N)
idx = idx(randperm(length(idx)));
s_idx = idx(1:min(length(idx), N));
end


function distMat = pairwiseDist(agglo, nodeIds, varargin)
    % distMat = pairwiseDist(agglo, nodeIds)
    %   Calculates the pair-wise distance between nodes `nodeIds` along the
    %   edges of the super-agglomerate `agglo`.
    %
    % Optional inputs
    %   voxelSize
    %     1x3 double vector with the voxel size. This vector is used in the
    %     calculation of edge lengths. Default value: [1, 1, 1].
    %
    %   outputFormat
    %     String indicating the output format. If `matrix`, the output
    %     value is the symmetric, square distance matrix. If `vector`, the
    %     lower-diagonal entries of the distance matrix are return as a
    %     vector. See also `squareform`. Default value: 'matrix'.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    opt = struct;
    opt.voxelSize = [1, 1, 1];
    opt.outputFormat = 'matrix';
    opt = Util.modifyStruct(opt, varargin{:});
    
    distMat = ...
        agglo.nodes(agglo.edges(:, 1), 1:3) ...
      - agglo.nodes(agglo.edges(:, 2), 1:3);
    distMat = distMat .* opt.voxelSize;
    distMat = sqrt(sum(distMat .* distMat, 2));
    
    distMat = graph( ...
        agglo.edges(:, 1), agglo.edges(:, 2), ...
        distMat, size(agglo.nodes, 1), 'OmitSelfLoops');
    
   [uniNodeIds, ~, nodeIds] = unique(nodeIds);
    distMat = distances(distMat, uniNodeIds, uniNodeIds);
    distMat = distMat(nodeIds, nodeIds);
    
    if strcmpi(opt.outputFormat, 'vector')
        distMat = squareform(distMat, 'tovector');
    end
end

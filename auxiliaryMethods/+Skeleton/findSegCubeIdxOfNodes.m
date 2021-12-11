function cubeIndices = findSegCubeIdxOfNodes( nodes, p )
%FINDSEGCUBEIDXOFNODES Find the segmentation cube indices for nodes.
% INPUT nodes: [Nx3] array of integer specifying the global coordinates of
%           the nodes.
%       p: Segmentation parameter struct.
% OUTPUT cubeIndices: Vector containing the segmentation cube index of each
%           input node. If a node is outside the bounding box the cube
%           index returned is 0.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

% prepare outout
nodeCount = size(nodes, 1);
cubeIndices = zeros(nodeCount, 1);

% validate coordinates
nodesOkay = all( ...
    bsxfun(@ge, nodes, p.bbox(:, 1)') ...
  & bsxfun(@le, nodes, p.bbox(:, 2)'), 2);

% only keep valid nodes
nodes = nodes(nodesOkay, :);

% make coordinates reslative to bounding box
% NOTE: numbering starts at ZERO
nodes = bsxfun( ...
    @minus, nodes, p.bbox(:, 1)');

% compute cube subscripts
cubeSubs = 1 + floor(bsxfun( ...
    @times, nodes, 1 ./ p.tileSize(:)'));

% compute linear cube indices
cubeIndices(nodesOkay) = sub2ind(size(p.local), ...
    cubeSubs(:, 1), cubeSubs(:, 2), cubeSubs(:, 3));

end

function segIds = getSegmentIdsOfSkelCellArray( p, skels )
%GETSEGMENTIDSOFSKELCELLARRAY As getSegmentIdsOfSkel for a cell array of
%skeletons.
% INPUT p: struct
%           Segmentation parameter struct.
%       skels: [Nx1] cell array
%           Cell array of skeleton objects.
% OUTPUT segIds: [Nx1] cell array
%           Cell array of same size. Each cell contains a cell array for
%           the trees of the skeleton with the segment ids of the
%           respective nodes.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%combine all nodes
nodes = cell2mat(cellfun(@getCoords, skels, 'UniformOutput', false));

% query segment IDs
segIds = Skeleton.getSegmentIdsOfNodes(p, nodes);

% redistribute results
numNodes = cell2mat(cellfun(@(x)x.numNodes(), skels, ...
    'UniformOutput', false));
segIds = mat2cell(segIds, numNodes, 1);
segIds = mat2cell(segIds, cellfun(@(x)x.numTrees(),skels), 1);

end

function X = getCoords(skel)
X = vertcat(skel.nodes{:});
X = X(:,1:3);
end


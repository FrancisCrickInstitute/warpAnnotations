function skel = deleteEdge( skel, varargin )
%DELETEEDGE Delete an edge between the specified nodes.
% Usage
%       skel.deleteEdge(edgeViaId)
%           Delete an edge by specifying the ids of the nodes. edgeViaId
%           should be a [Nx2] int containing the edges between the node ids
%           that should be deleted.
%       skel.deleteEdge(edgeViaIdx, treeIdx)
%           Delete an edge by specifying the nodes indices and the
%           respective tree. edgeViaIds must be a [Nx2] int containing the
%           edges between node indices that should be deleted. The nodes
%           are deleted for the specified treeIdx.
%
% NOTE Deleting an edge should split a tree. Use splitCC to also split the
% tree in the skeleton class.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if length(varargin) == 1
    % delete edges by id
    edges = varargin{1};
    assert(size(edges, 2) == 2, 'edgeViaId hat the wrong shape');
    
    % get node indices
    [treeIdx, nodeIdx] = skel.getNodesWithIDs(edges(:));
    treeIdx = reshape(treeIdx, [], 2);
    nodeIdx = reshape(nodeIdx, [], 2);
    
    % sanity check
    tmp = find(treeIdx(:,1) ~= treeIdx(:,2));
    if ~isempty(tmp)
        error('The nodes in edgeViaId row %d are in different trees', ...
            tmp(1));
    end
    treeIdx = treeIdx(:,1);
    
    for i = 1:length(treeIdx)
        toDelIdx = Graph.findEdges(skel.edges{treeIdx(i)}, nodeIdx(i,:));
        skel.edges{treeIdx(i)}(toDelIdx{1}, :) = [];
    end
elseif length(varargin) == 2
    edges = varargin{1};
    assert(size(edges, 2) == 2, 'edgeViaId hat the wrong shape');
    
    treeIdx = varargin{2};
    toDelIdx = Graph.findEdges(skel.edges{treeIdx}, edges);
    
    skel.edges{treeIdx}(cell2mat(toDelIdx), :) = [];
else
    error('Unsupported number of input arguments.');
end

end


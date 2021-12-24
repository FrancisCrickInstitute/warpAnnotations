function [skelNew, origTreeIdx, origNodeIdx] = splitCC( skel, treeIndices )
%SPLITCC Split each tree of a skeleton into connected components.
% INPUT treeIndices: (Optional) [Nx1] int or logical
%           Linear or logical indices of the trees of interest.
% OUTPUT skelNew: skeleton object
%           A skeleton object with the specified trees split into connected
%           components. The ordering of trees is such that for each
%           original tree the connected components are added sequentially
%           to newly created skelNew object. See also the origTreeIdx.
%        origTreeIdx: [Nx1] int
%           Cell array specifying the indices of the tree in the original
%           skeleton from which the trees in skelNew originate.
%        origNodeIdx: [Nx1] cell
%           Cell array containing the node indices of the nodes in the
%           original tracing for the respective tree in origTreeIdx.
%
% NOTE Empty trees will be discarded.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices', 'var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

skelNew = skeleton();
skelNew.scale = skel.scale;
skelNew.parameters = skel.parameters;
skelNew.filename=skel.filename;
origTreeIdx = zeros(0, 1);
origNodeIdx = cell(0, 1);
for tr = treeIndices
    numNodes = size(skel.nodes{tr}, 1);
    % add highest node idx to edge list (required if last node node in
    % edge list e.g. also for single node)
    edges = [skel.edges{tr}; [numNodes, numNodes]];
    
    if isempty(skel.nodes{tr})
        continue;
    end
    comps = Graph.findConnectedComponents(edges, false);
    comps = cellfun(@sort, comps, 'UniformOutput', false); %just to make sure
    origTreeIdx = cat(1, origTreeIdx, repelem(tr, length(comps), 1));
    for newTr = 1:length(comps)
        
        %renumber old edges
        edgeIdx = all(ismember(skel.edges{tr}, comps{newTr}), 2);
        newEdges = skel.edges{tr}(edgeIdx,:);
        [~,~,ic] = unique(newEdges);
        newEdges = reshape(ic, size(newEdges));
        
        %add connected component as tree
        skelNew = skelNew.addTree([], skel.nodes{tr}(comps{newTr},1:3), ...
            newEdges, [], [], ...
            {skel.nodesAsStruct{tr}(comps{newTr}).comment});
    end
    origNodeIdx = cat(1, origNodeIdx, comps);
end

%keep remaining trees unchanged
if ~isempty(setdiff(1:skel.numTrees(), treeIndices))
    skelNew = skelNew.addTreeFromSkel(skel, ...
        setdiff(1:skel.numTrees(), treeIndices));
    origNodeIdx{end+1, skelNew.numTrees()} = [];
end

%sanity check
if size(skel.getNodes(), 1) ~= size(skelNew.getNodes(), 1)
    error('Something went wrong.');
end

end


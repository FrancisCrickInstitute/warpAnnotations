function [ groupedNodes, outOfBBox ] = findSegCubeIdxOfSkel( skel, p, treeIndices )
%FINDSEGCUBEIDXOFSKEL Find the nodes of a skeleton in each segmentation
%cube.
% INPUT skel: A skeleton object.
%       p: Segmentation parameter file.
%       treeIndices: (Optional) Vector of integer containing the linear
%           indices of the trees of interest.
%           (Default: all trees)
% OUTPUT groupedNodes: Cell array of struct. Each cell contains the a
%           struct corresponding to a cube in p.local. The struct contains
%           the fields
%               'cubeIdx': Linear index of the cube in p.local.
%               'nodes': Cell array of length(treeIndices) containing the
%                   nodes of each tree in the cube 'cubeIdx'.
%               'nodeIdxInTree': Cell array of length(treeIndices)
%                   containing the linear indices of the nodes in the
%                   corresponding tree in treeIndices.
%        outOfBBox: Cell array of length(treeIndices). Each cell contains
%           the linear indices of the nodes of the corresponding tree in
%           treeIndices outside the segmentation bounding box.
%
% see also Skeleton.findSegCubeIdxOfNodes
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:length(skel.nodes);
elseif ~isrow(treeIndices)
    treeIndices = treeIndices';
end

%intialize output variables
numCubes = numel(p.local);
groupedNodes = cell(numCubes,1);
for cube = 1:numCubes
    groupedNodes{cube} = struct('cubeIdx',cube);
    groupedNodes{cube}.nodes = cell(length(treeIndices),1);
    groupedNodes{cube}.nodeIdxInTree = cell(length(treeIndices),1);
end
outOfBBox = cell(length(treeIndices),1);

for tr = 1:length(treeIndices)
    fprintf('[%s] findSegCubeIDxOfSkel - Processing tree %d/%d\n', ...
        datestr(now),tr,length(treeIndices));
    %get cube indices of each node in tree
    cubeIndices = Skeleton.findSegCubeIdxOfNodes( ...
        skel.nodes{treeIndices(tr)}(:,1:3),p);
    outOfBBox{tr} = find(~cubeIndices);

    %add nodes to corresponding cube in grouped nodes
    cubeIDs = unique(cubeIndices(:));
    cubeIDs(cubeIDs == 0) = [];
    for i = 1:length(cubeIDs)
        nodes_idx_in_cube = find(cubeIndices == cubeIDs(i));
        groupedNodes{cubeIDs(i)}.nodeIdxInTree{tr} = nodes_idx_in_cube;
        groupedNodes{cubeIDs(i)}.nodes{tr} = skel.nodes{treeIndices(tr)}...
            (nodes_idx_in_cube,1:3);
    end
end

%delete cells in grouped nodes without nodes
toDel = cellfun(@(x)all(cellfun(@isempty,x.nodes)),groupedNodes);
groupedNodes(toDel) = [];

end

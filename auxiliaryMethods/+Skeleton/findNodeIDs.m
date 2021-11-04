function [ segIDs, counts ] = findNodeIDs( nodes, zeroOfCube, seg, mode )
%FINDNODEIDS Find the segmentation IDs of nodes.
% INPUT nodes: Integer array containing the global coordinates of the nodes.
%       zeroOfCube: The global coordinate of the first [1,1,1] entry in
%                   segmentation (e.g. pCube(cubeID).bboxBig(:,1)
%       seg: The segmentation matrix.
%       mode: String specifying the modes
%           'single': Find the segment ID for each node
%           'collective': Find the unique segment IDs of all nodes within
%               the local cube
% OUTPUT segIDs: Integer array containing the nodes IDs.
%           In 'collective' mode this cotains the unique sorted IDs.
%           In 'single' mode the array of IDs has the same length as the
%           number of nodes and contains the segment IDs of each
%           corresponding node.
%        counts: The number of nodes in each segment in "collective" mode.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>


if ~isrow(zeroOfCube)
    zeroOfCube = zeroOfCube';
end

relCoords = bsxfun(@minus,nodes,zeroOfCube(1,:) - [1, 1, 1]);
skelSegIDs = seg(sub2ind(size(seg),relCoords(:,1),relCoords(:,2),relCoords(:,3)));

switch mode
    case 'single'
        segIDs = skelSegIDs;
        counts = [];
    case 'collective'
        %delete zero segments (walls)
        skelSegIDs(skelSegIDs == 0) = [];
        uSkelSegIDs = unique(skelSegIDs);
        counts = histc(skelSegIDs,uSkelSegIDs);
        segIDs = uSkelSegIDs;
    otherwise
        error('Specify findNode mode.');
end



end

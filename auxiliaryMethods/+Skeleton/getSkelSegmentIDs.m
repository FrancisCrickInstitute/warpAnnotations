function [segIDs, segVol, numSegIDs] = getSkelSegmentIDs( skel, p, treeIndices, fastMode, radii, useClosestID )
%GETSKELSEGMENTIDS Get the segment ID for each node in a skeleton.
% INPUT skel: A skeleton object.
%       p: Segmentation parameter struct.
%       treeIndices: (Optional) Array of integer containing the indices of
%           the trees of interest.
%           (Default: all trees)
%       fastMode: (Optional) Boolean specifying mode for segVol calculation.
%           true: Calculate on "segments" data structure (bboxSmall)
%           false: Calculate on "seg" data structure (bboxBig)
%           (Default: true)
%       radii: (Optional) Mapping of the global segments.
%           (Default: If nargout>2: radii = [1:3])
%       useClosestID: (Optional) Bool specifying whether always the ID of
%           the closest segment for each skeleton node should be used. This
%           will automatically select the smallest ID in the 26
%           neighborhood of a skeleton node if the node is not placed
%           inside a segment.
%           (Default: false)
% OUTPUT segIDs: Cell array of length(treeIndices). Each cell contains a
%           vector with the global segment IDs for each node in the
%           corresponding tree. If a node is outside the bounding box it
%           will get the segment ID -1.
%        segVol: Cell array of length(tr). Each cell contains a vector with
%           the volume (number of voxels) for the segment of each node in
%           the corresponding tree.
%        numSegIDs: Cell array of length(tr). Each cell contains a [Nxr] matrix
%           with the number of touched segments for spheres of different radii
%           around each node.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% 08 Oct 2015: Added node placement noise calculation
%              (Thomas Kipf <thomas.kipf@brain.mpg.de>)
% 12 Oct 2015: Fixed tree indexing
%              (Thomas Kipf <thomas.kipf@brain.mpg.de>)

if ~exist('treeIndices','var') || isempty(treeIndices) || sum(~treeIndices)
    treeIndices = 1:skel.numTrees();
end
if (~exist('fastMode','var') || isempty(fastMode))
    fastMode = true;
end
if (~exist('radii','var') || isempty(radii))
    radii = 1:5;
end
if ~exist('useClosestID','var') || isempty(useClosestID)
    useClosestID = false;
end

[groupedNodes, outOfBBox] = Skeleton.findSegCubeIdxOfSkel(skel, p, treeIndices);
segIDs = cellfun(@(x)zeros(size(x,1),1),skel.nodes(treeIndices),'UniformOutput',false);
segVol = cellfun(@(x)zeros(size(x,1),1),skel.nodes(treeIndices),'UniformOutput',false);

%set -1 for nodes out of segmentation bounding box
for tr = 1:length(treeIndices)
    segIDs{tr}(outOfBBox{tr}) = -1;
end

if nargout > 2
    numSegIDs = cellfun(@(x)zeros(size(x,1),length(radii)),skel.nodes,'UniformOutput',false);
end

%loop over segmentation cube and get segment ids of nodes
for i = 1:length(groupedNodes)
    fprintf('[%s] getSkelSegmentIDs - Processing local cube %d/%d\n', ...
            datestr(now),i,length(groupedNodes));
    pCube = p.local(groupedNodes{i}.cubeIdx);
    
    matfile = load(pCube.segFile);
    seg = matfile.seg;
    
    m = load([pCube.saveFolder 'localToGlobalSegId.mat']);
    globalIds = m.globalIds;
    localIds = m.localIds;
    
    for tr = 1:length(treeIndices)
        nodes = groupedNodes{i}.nodes{tr};
        
        % skip tree if there are no nodes
        if isempty(nodes)
            continue;
        end
        
        currIDs = Skeleton.findNodeIDs(nodes, pCube.bboxBig(:,1), seg, 'single');
        currIDs = Seg.Local.localGlobalIDConversion('LocalToGlobal', ...
            {localIds, globalIds}, currIDs);
        
        if useClosestID
            zeroOfCube = pCube.bboxBig(:,1)';
            rel_coords = bsxfun(@minus, nodes, zeroOfCube(1,:) - [1 1 1]);
            
            for j = 1:size(nodes, 1) % ~0.02sec per node
                
                if currIDs(j) == 0
                    currIDs(j) = getClosestID(seg, rel_coords(j,:));
                    currIDs(j) = Seg.Local.localGlobalIDConversion('LocalToGlobal', ...
                        {localIds, globalIds}, currIDs(j));
                end
            end
        end
        
        if nargout > 1 % Calculate segment volume
            currVol = zeros(length(currIDs),1);
            idx = currIDs > 0;
            
            if fastMode
                matfile = load(pCube.segmentFile);
                segments = matfile.segments;
                tmp = Seg.Local.getSegmentSize(segments, currIDs(idx));
            else
                tmp = Seg.Local.getSegmentSize(seg, currIDs(idx));
            end
            
            currVol(idx) = tmp;
            segVol{tr}(groupedNodes{i}.nodeIdxInTree{tr}) = currVol;
        end
        
        if nargout > 2 % Calculate number of segments around node for r=radii
            zeroOfCube = pCube.bboxBig(:,1)';
            rel_coords = bsxfun(@minus, nodes, zeroOfCube(1,:) - [1 1 1]);
            for j = 1:size(nodes, 1) % ~0.02sec per node
                nodeID = groupedNodes{i}.nodeIdxInTree{tr}(j);
                numSegIDs{tr}(nodeID, :) = getNumSegIDsWithinSpheres(nodeID, ...
                    seg, rel_coords(j,:), radii);
            end
        end
        
        segIDs{tr}(groupedNodes{i}.nodeIdxInTree{tr}) = currIDs;
    end
end
end

function id = getClosestID(seg, c)
%The the smallest ID within the 26 neighborhood of a point.
pts = Util.getPointsInBall(c, 1.9);
inBBoxSmall = all(bsxfun(@ge,pts,[257, 257, 129]),2) & all(bsxfun(@le,pts,[768,768,384]),2);
pts = pts( inBBoxSmall ,:); %sort out points out of bboxSmall
segIDs = seg(sub2ind(size(seg), pts(:,1), pts(:,2), pts(:,3)));
segIDs = unique(segIDs);
segIDs(segIDs == 0) = [];
id = segIDs(1);
end

function numSegIDs = getNumSegIDsWithinSpheres(nodeID, seg, c, radii)
% Get number of segment IDs within spheres of different radii
numSegIDs = zeros(1, length(radii));
for r = 1:length(radii)
    pts = Util.getPointsOnSphere(c, radii(r));
    segIDs = seg(sub2ind(size(seg), pts(:,1), pts(:,2), pts(:,3)));
    segIDs = unique(segIDs);
    segIDs(segIDs == 0) = [];
    numSegIDs(1, r) = length(segIDs);
end
end

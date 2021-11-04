function [ node, dist ] = findClosestNode( node, otherNodes, globalCoMList, ...
  scale )
%FINDCLOSESTNODE From a list of nodes, find node with minimum euclidean
%distance to a given node.
% INPUT node: (Mapped) global segment ID of a node.
%       otherNodes: List of nodes as (mapped) global segment IDs.
%       globalCoMList: [Nx3] numeric array specifying the global
%           coordinates of the center of mass for each mapped segment id.
%       scale: (Optional) Integer vector of length 3 specifying the voxel
%              scale when converting to nm.
%              (Default: [11.24, 11.24, 28])
% OUTPUT node: The closest node.
%        dist: Distance between original node and closest node.
% Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
% (adapted from Graph.constrainCoMDist by Benedikt Staffler)

  if ~exist('scale','var') || isempty(scale)
      scale = [11.24, 11.24, 28];
  elseif iscolum(scale)
      scale = scale';
  end

  % Get com of all nodes and nodes of interest
  comNode = globalCoMList(node,:);
  comOtherNodes = globalCoMList(otherNodes,:);

  % Convert to nm scale
  comNode = bsxfun(@times,comNode,scale);
  comOtherNodes = bsxfun(@times,comOtherNodes,scale);

  % Calculate pairwise distance and sort out everything above threshold
  D = pdist2(comNode, comOtherNodes);
  [dist, idx] = min(D);

  node = otherNodes(idx);

end

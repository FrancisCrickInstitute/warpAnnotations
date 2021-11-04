function [ pairwiseDist ] = getPairwiseDistance( nodes, otherNodes, ...
  globalCoMList, scale )
%FINDCLOSESTNODE Find pairwise euclidean distance of two list of nodes.
% INPUT nodes: List of nodes as (mapped) global segment IDs.
%       otherNodes: List of nodes as (mapped) global segment IDs.
%       globalCoMList: [Nx3] numeric array specifying the global
%           coordinates of the center of mass for each mapped segment id.
%       scale: (Optional) Integer vector of length 3 specifying the voxel
%              scale when converting to nm.
%              (Default: [11.24, 11.24, 28])
% OUTPUT pairwiseDist: Pairwise distance matrix, with same sorting as
%               nodes & otherNodes
% Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
% (adapted from Graph.constrainCoMDist by Benedikt Staffler)

  if ~exist('scale','var') || isempty(scale)
      scale = [11.24, 11.24, 28];
  elseif iscolum(scale)
      scale = scale';
  end

  % Get com of all nodes of interest
  comNodes = globalCoMList(nodes,:);
  comOtherNodes = globalCoMList(otherNodes,:);

  % Convert to nm scale
  comNodes = bsxfun(@times,comNodes,scale);
  comOtherNodes = bsxfun(@times,comOtherNodes,scale);

  % Calculate pairwise distance
  pairwiseDist = pdist2(comNodes, comOtherNodes);

end

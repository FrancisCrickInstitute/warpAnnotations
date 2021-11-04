function [ seg, edges, borders, bordersIn2Out ] = applySegEquiv( ...
    eClasses, seg, edges, borders, segments )
%APPLYSEGEQUIV Merge the specified segments and recalculate the edges and
%borders.
% INPUT eClasses: [Nx1] cell array. Each entry contains an [Mx1] numerical
%           array specifying the segment IDs which should be merged.
%       seg: 3D array of integer containing a segmentation.
%       edges: [Nx2] array of integer containing the edges in the adjacency
%           graph contained in seg.
%       borders: Struct array containing the borders between edges.
% OUTPUT seg: The updated segmentation.
%        edges: [Nx2] the udpated edge list.
%        borders: The updated borders.
%        borderIn2Out: [Nx1] cell
%           Cell array of same length as borders output containing the
%           linear indices of the input borders that are combined into the
%           corresponding output border.
%
% NOTE Make sure that all inputs use the same type of ID (i.e. global or
%      local IDs in eClasses, seg, edges and segments).
%
% see also Seg.Local.applyGPSegEquiv
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

[edges, borders, ~, bordersIn2Out] = Seg.Local.applySegEquiv2EdgesAndBorders(...
    eClasses, edges, borders, size(seg));
seg = Seg.Local.applySegEquivToSeg(eClasses, seg, segments);
seg = Seg.Local.closeGaps(seg);

end

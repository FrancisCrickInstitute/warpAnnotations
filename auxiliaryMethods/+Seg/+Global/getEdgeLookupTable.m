function [ idsToEdge ] = getEdgeLookupTable( edges, exactPos )
%GETEDGELOOKUPTABLE Create a lookup table for IDs in the edge list.
% INPUT edges: [Nx2] array of integer containing the edges of the adjacency
%           graph (e.g. output of Seg.Global.getGlobalEdges)
%       exactPos: (Optional) logical
%           Flag indicating to output the exact position of each id and not
%           just the row index.
%           (Default: false)
% OUTPUT idsToEdge: Cell array of length(max(edges(:)). The i-th
%           cell contains the linear indices of the rows in edges which
%           contain the id i.
%
% NOTE The output might be quite sparse and thus it can be required to cast
%      to cast it to Util.SparseCellArray arrays when saving it.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('exactPos', 'var') || isempty(exactPos)
    exactPos = false;
end

if exactPos
    [comps, id] = Util.group2Cell(edges);
else
    [comps, id] = Util.group2Cell(edges, false, true);
end
idsToEdge = cell(max(edges(:)),1);
idsToEdge(id) = comps;

end

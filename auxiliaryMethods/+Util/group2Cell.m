function [ comps, groupId, groupSize ] = group2Cell( group, ...
    discardSingleGroups, rowIdx )
%GROUP2CELL Combine indices of the same group in a cell array.
% INPUT group: nd int array
%           Integer group id for the respective index.
%       discardSingleGroups: (Optional) logical
%           Flag to discard groups consisting of one element only.
%           (Default: false)
%       rowIdx: (Optional) logical
%           Flag indicating that only the row indices of a [NxM] int group
%           input are grouped.
%           (Default: false)
% OUTPUT comps: [Nx1] cell
%           Cell array of length max(group). Each cell contains all indices
%           of one group. Groups are sorted in increasing order.
%        groupId: [Nx1] int
%           Id of the respective group in comps.
%        groupSize: [Nx1] int
%           The number of elements in the corresponding comps entry.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('rowIdx', 'var') || isempty(rowIdx)
    rowIdx = false;
end

[sGroup, idx] = sort(group(:));
if rowIdx
    [idx, ~] = ind2sub(size(group), idx);
end
groupStartIdx = [true; diff(sGroup) > 0];

if exist('discardSingleGroups', 'var') && discardSingleGroups
    %delete single groups
    toDel = [groupStartIdx(1:end-1) & groupStartIdx(2:end); ...
        groupStartIdx(end)];
    groupStartIdx = groupStartIdx(~toDel);
    sGroup = sGroup(~toDel);
    idx = idx(~toDel);
end

groupSize = diff([find(groupStartIdx); length(groupStartIdx) + 1]);
comps = mat2cell(idx, groupSize, 1);
groupId = sGroup(groupStartIdx);

if rowIdx
    comps = cellfun(@unique, comps, 'UniformOutput', false);
end

end


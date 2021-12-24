function skel = resetTrees(skel, baseName)
%Reset the ids and  names of the trees. The tree name will be a
% base name followed by its id.
% INPUT baseName: (Optional) string
%       	Default name followed by the tree id.
%           (Default: 'Tree')
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('baseName','var') || isempty(baseName)
    baseName = 'Tree';
end

skel.thingIDs = (1:skel.numTrees)';
skel.names = arrayfun(@(x)[baseName, sprintf('%03d',x)], ...
    skel.thingIDs, 'UniformOutput',false);
end
function skel = fromCellArray( c )
%FROMCELLARRAY Combine a cell array of skeletons into a single skeleton.
% INPUT c: [Nx1] cell
%           Cell array of skeleton object.s
% OUTPUT skel: skeleton object
%           A single skeleton object containing all skeletons.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

skel = c{1};
for i = 2:length(c)
    skel = skel.addTreeFromSkel(c{i});
end

end


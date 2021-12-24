function idx = findEClass( eClasses, ids )
%FINDECLASS Find a list of IDs in a list of equivalence classes.
% INPUT eClasses: [Nx1] cell array of integer arrays.
%       ids: [Nx1] int array of ids.
% OUTPUT idx: [Nx1] int array of linear indices for the eClass of the
%           corresponding id.
%
% see also Seg.Global.eClassLookup
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

eClassLookup = Seg.Global.eClassLookup(eClasses, max(ids));
idx = full(eClassLookup(ids));

end


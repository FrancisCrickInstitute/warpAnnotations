function [ isEq, idx ] = checkIsPerm( c1, c2, sortCells )
%CHECKISPERM Check if two cell arrays are equal modulo permutation.
% INPUT c1: [Nx1] cell
%       c2: [Nx1] cell
%       sortCells: (Optional) logical
%           Flag specifying if each cell should be sorted.
%           (Default: false)
% OUTPUT isEq: logical
%           True if there is a permutation idx such that
%           isequal(c1, c2(idx)).
%        idx: [Nx1] int
%           Permutation idx such that isequal(c1, c2(idx)).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if exist('sortCells', 'var') && sortCells
    c1 = cellfun(@sort, c1, 'UniformOutput', false);
    c2 = cellfun(@sort, c2, 'UniformOutput', false);
end

if size(c1) ~= size(c2)
    error('Both cells need to have the same length');
end

idx = (1:length(c2))';

isEq = true;
for i = 1:length(c1) - 1
    found = false;
    for j = i:length(c2)
        if isequal(c1{i}, c2{idx(j)});
            idx([i, j]) = idx([j, i]);
            found = true;
            break
        end
    end
    if ~found
        isEq = false;
        idx = [];
        break;
    end
end


end


function [C, I] = sortBy(A, B, varargin)
    % [C, I] = sortBy(A, B, varargin)
    %   Takes two vectors, A and B, of the same size and sorts A by B.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % Sanity checks
    assert(isequal(size(A), size(B)));
    assert(isvector(A), 'Only vector arguments are supported');
    
    % Main logic
   [~, I] = sort(B, varargin{:});
    C = A(I);
end

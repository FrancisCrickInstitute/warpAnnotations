function [ vector ] = convertToRow( vector )
%CONVERTTOCOLUMN Short Method to convert to column vector needed in for
%loops
% Author: Ali Karimi <ali.karimi@brain.mpg.de>
assert(isvector(vector),'The input is not a vector');
if ~isrow(vector)
    vector=vector';
end
end


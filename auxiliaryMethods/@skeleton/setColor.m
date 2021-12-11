function [ obj ] = setColor( obj,color )
%SETCOLOR set all the trees to the same color
% Author: Ali Karimi<ali.karimi@brain.mpg.de>
for tr=1:obj.numTrees
    obj.colors{tr}=[color,1];
end
end


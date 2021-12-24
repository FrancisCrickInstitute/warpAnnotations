function [ numberArray ] = convertCell2Array( inputCellArray )
%Checks the size of cell Array, concatenate in dim1 if larger than 1 and
%convert to normal array if size 1
if length(inputCellArray)==1
    numberArray=inputCellArray{1};
else
    numberArray=cat(1,inputCellArray{:});
end

end


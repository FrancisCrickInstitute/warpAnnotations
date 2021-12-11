function scaledCoordinates=setScale(coordinates,scalingFactor)
%SETSCALE This static method scales the coordinates (Nx3) using the scaling
%factor(size:1x3)

if iscell (coordinates)
    coordinates=cell2mat(coordinates);
end
assert(isequal(size(scalingFactor),[1,3]),'scale size is not [1,3]');
assert(size(coordinates,2)==3,'coordinates do not have size 3');
if size(coordinates,2)==3
    scaledCoordinates=bsxfun(@times,coordinates,scalingFactor);
else
    disp('not coordinate returning the original Value!!')
    scaledCoordinates=coordinates;
end
end


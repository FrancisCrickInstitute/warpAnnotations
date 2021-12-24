function obj = invertDimensions(obj, dsize, dir_array)
% dsize: size of the dataset in pixels [width height depth]
% dir_array: [hFlip vFlip zRev]
if dir_array(1) == 1
    obj = obj.invertDimension(dsize, 1);
end
if dir_array(2) == 1
    obj = obj.invertDimension(dsize, 2);
end
if dir_array(3) == 1
    obj = obj.invertDimension(dsize, 3);
end

end

function obj = changeChirality(obj,chirArray,dsize)
% chirArray: [hFlip vFlip zRev]
% dsize: size of the dataset in pixels [width height depth]
% apply hFlip
if chirArray(1)==1
    obj = transformChirality(obj,dsize,1);
end
% apply vFlip
if chirArray(2)==1
    obj = transformChirality(obj,dsize,2);
end
% apply zRev
if chirArray(3)==1
    obj = transformChirality(obj,dsize,3);
end

end
function img = readDMFile(filename)
    
    evalc('temp = bfopen(filename)');
    img = im2uint8(temp{1}{1});

end

function m = tryLoad(filename)
counter = 1;
while 1
    try
        m = load(filename);
    catch ME
        if strcmp(ME.identifier,'MATLAB:load:unableToReadMatFile') 
            if counter < 10
                pause(6)
                counter = counter +1;
                continue
            else
                error('Tried 10 times to load mat file but it is still corrupt')
            end
        else
            error('Some error occured during loading the mat file:\n%s',ME.message)
        end
    end
    break
end
end
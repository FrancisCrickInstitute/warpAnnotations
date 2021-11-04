function [ content ] = readJson( filename )
%READJSON Save content of json file into a struct.
% INPUT filename: Full path to json file.
% OUTPUT content: Content of the json file as MATLAB struct.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

fileID = fopen(filename);
str = fscanf(fileID,'%s');
content = fromjson(str);
fclose(fileID);

end


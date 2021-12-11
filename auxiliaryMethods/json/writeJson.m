function writeJson( filepath, data )
%WRITEJSON Write data to json file.
% INPUT filepath: Full path to file including extension.
%       data: Matlab struct containing the key-value pairs for the json 
%           file.
% Author: Manuel Berning <manuel.berning@brain.mpg.de>

file_id = fopen(filepath, 'w');
rawData = tojson(data); %using json-c
fprintf(file_id, '%s', rawData);
fclose(file_id);

end


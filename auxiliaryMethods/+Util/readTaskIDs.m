function [nodes] = readTaskIDs(IDs_path)
seedfile = fullfile(IDs_path);
fileID = fopen(seedfile,'r');
% skip first line if it is there
if strcmp(char(fread(fileID,6)'),'taskId')
    fseek(fileID,25,'bof');
end
data = textscan(fileID, '%s %s (%f %f %f)','Delimiter',{','});

nodes = cat(2,num2cell(data{3}), num2cell(data{4}), num2cell(data{5}), data{1} );
end


 
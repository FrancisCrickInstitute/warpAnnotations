function [ path ] = addFilesep( path )
%ADDFILESEP Add a file separator at the end of a path if it does not
%already have one.
% INPUT path: A path string.
% OUTPUT path: The input string containing a fileseparator at the end.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~strcmp(path(end),filesep)
    path = [path filesep];
end

end

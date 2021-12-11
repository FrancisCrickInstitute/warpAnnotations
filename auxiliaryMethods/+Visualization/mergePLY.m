function mergePLY(PLY_folder_source, FILENAMES_TO_BE_MERGED, FILENAME_out)

% ------------------------------------------------------
% merge multiple PLY files into one PLY file
% you need readPLY.m and writePLY.m
% Heiko Wissler, 2018

% example to load all .ply files of a given folder
% and write it into one FILENAME_out.ply:

% PLY_folder_source = 'z:\Matlab\PLYs\example_PLYs'; %folder to the PLY files
% FILENAME_out = 'Z:\Matlab\PLYs\all_together.ply'; % path and filename of the files to be written
% FILENAMES_TO_BE_MERGED = dir([num2str(PLY_folder_source) '\*.ply']);
% mergePLY(PLY_folder_source, FILENAMES_TO_BE_MERGED, FILENAME_out)
% ------------------------------------------------------



%read first issf:
issfs_all = readPLY([PLY_folder_source '\' getfield(FILENAMES_TO_BE_MERGED, {1,1}, 'name')]);

%add option for multiple versions of FILENAMES_TO_BE_MERGED
if size(FILENAMES_TO_BE_MERGED, 1) > size(FILENAMES_TO_BE_MERGED, 2)
    ThisSize = size(FILENAMES_TO_BE_MERGED, 1);
else
    ThisSize = size(FILENAMES_TO_BE_MERGED, 2);
end

%add all other issf into the first:
for i = 2:ThisSize
    disp(['merging ' num2str(PLY_folder_source) '\' num2str(FILENAMES_TO_BE_MERGED(i).name)])
    actual_issf = readPLY([PLY_folder_source '\' num2str(FILENAMES_TO_BE_MERGED(i).name)]);
    size_issf_all = size(issfs_all.vertices, 1);
    for k = 1:size(actual_issf.faces,1)
        actual_issf.faces(k,1) = actual_issf.faces(k,1) + size_issf_all;
        actual_issf.faces(k,2) = actual_issf.faces(k,2) + size_issf_all;
        actual_issf.faces(k,3) = actual_issf.faces(k,3) + size_issf_all;
    end
    
    issfs_all.vertices = [issfs_all.vertices; actual_issf.vertices];
    issfs_all.faces = [issfs_all.faces; actual_issf.faces];
    
end

%write the new PLY
disp(['writing ' (FILENAME_out)])
writePLY(issfs_all, ones(1,3), FILENAME_out)

end




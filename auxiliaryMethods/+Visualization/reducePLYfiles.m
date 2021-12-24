function reducePLYfiles(PLY_folder_source, FILENAME, PLY_max)

% ------------------------------------------------------
% reduce the number of PLY files in a given folder to PLY_max by merging them
% you need readPLY.m, writePLY.m and mergePLY.m
% Heiko Wissler, 2018

% example to load all .ply files of a given folder,
% merge them and write PLY_max number of files:

% PLY_folder_source = 'z:\Matlab\PLYs\example_PLYs'; %folder to the PLY files
% FILENAME = 'Z:\Matlab\PLYs\all_together'; % path and filename of the files to be written
% PLY_max = 2; %merge PLY files to get max. PLY_max files
% ------------------------------------------------------

%FILENAMES_TO_BE_MERGED = dir(PLY_folder);
original_filenames = dir([(PLY_folder_source) '\*.ply']);
random_list = randperm(size(original_filenames, 1));

%define how many files needs to be merged and how many rounds of merging are needed
filesToBeMerged = ceil(size(original_filenames, 1)/PLY_max);
rounds = ceil(size(original_filenames, 1)/filesToBeMerged);

%write FILENAMES_TO_BE_MERGED in chunks and give to mergePLY
for i = 1:rounds;
    clear FILENAMES_TO_BE_MERGED
    for j = filesToBeMerged * (i) - (filesToBeMerged - 1) : filesToBeMerged * (i);
        try
            [FILENAMES_TO_BE_MERGED(j).name] = [original_filenames(random_list(1,j)).name];
        catch
            j = j + 1;
        end
    end
    
    %remove empty elements
    empty_elems = arrayfun(@(s) all(structfun(@isempty,s)), FILENAMES_TO_BE_MERGED);
    FILENAMES_TO_BE_MERGED(empty_elems) = [];
    
    %get filename and sent job to mergePLY
    FILENAME_out = ([num2str(FILENAME) '_' num2str(filesToBeMerged) '_' num2str(i) '.ply']);
    mergePLY (PLY_folder_source, FILENAMES_TO_BE_MERGED, FILENAME_out)
    
end

end


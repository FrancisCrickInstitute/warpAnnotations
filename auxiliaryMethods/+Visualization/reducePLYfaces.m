function reducePLYfaces(PLY_folder_source, FACES_MAX, FOLDER_OUT)

% ------------------------------------------------------
% reduce the number of faces and vertices of all PLY files in a given folder
% in the end you have the same PLY files but the sum of their faces is FACES_MAX
% you need readPLY.m and writePLY.m 
% Heiko Wissler, 2018

% example to load all .ply files of a given folder and reduce their faces:

% PLY_folder_source = 'Z:\Matlab\PLYs\test_PLYs';
% FACES_MAX = 100000000; %100000000 is about the limit on a good workstation
% FOLDER_OUT = 'Z:\Matlab\PLYs\test_PLYs_reduced';
% reducePLYfaces(PLY_folder_source, FACES_MAX, FOLDER_OUT)
% ------------------------------------------------------


original_filenames = dir([(PLY_folder_source) '\*.ply']);
format short g %show less digits for all numbers
tic

%get total number of faces of all PLYs
disp('getting the total number of faces to calculate the needed reduce-factor')
TotalPlyFaces = 0;
for i = 1:size(original_filenames, 1)
    ActualPLY = readPLY([PLY_folder_source '\' [original_filenames(i).name]]);
    ActualPlySizeFaces = size(ActualPLY.faces,1);
    TotalPlyFaces = TotalPlyFaces + ActualPlySizeFaces;
    disp(['processing file #' num2str(i) '/' num2str(size(original_filenames, 1)) '.....sum faces: ' num2str(TotalPlyFaces)])
end

%get the needed reduce factor
ReduceFactor = FACES_MAX / TotalPlyFaces;
disp(['reduce factor is: ' num2str(ReduceFactor)])
timeToGetReduceFactor_hours = (toc/3600);

%load and reduce the PLY files and write to given folder
if ReduceFactor < 1
    for i = 1244:size(original_filenames, 1)
        ActualPLY = readPLY([PLY_folder_source '\' [original_filenames(i).name]]);
        try
            ActualPLY_reduced = reducepatch(ActualPLY, ReduceFactor);
        end
        FILENAME = ([num2str(FOLDER_OUT) '\' num2str(original_filenames(i).name) '_reduced_' num2str(round(ReduceFactor, 3)) '.ply']) ; % path and filename of the files to be written
        FILENAME_out = strrep(FILENAME, '.ply_', '_');
        writePLY(ActualPLY_reduced, ones(1,3), FILENAME_out)
        disp(['writing ' num2str(FILENAME_out)])
    end
else
    disp(['no need to reduce files because all PLY files together already have less than ' num2str(FACES_MAX) ' faces'])
end
timeToGetNewPlyWritten_hours = (toc/3600);    
disp(['all files successfully written into ' num2str(FOLDER_OUT) '. This took only ' num2str(timeToGetNewPlyWritten_hours) ' hours.'])


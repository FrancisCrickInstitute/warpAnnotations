% Script to write all .raw files from Knossos-hierarchy into one big .raw file theat can be read by Amira
clear
clc

%% SECTION 1
% Set parameters: E.g. this should be the only section to change when generating a new .raw file
% Source of the data (i noticed you had something else that I did not have access to it)
% Usually it is best to mount folders so that you have the same absolute paths on all devices
source_path='/camp/svc/www/proj-emschaefer/webknossos-datastore/C408_aligned_matlab/color/4-4-4'; %path to the x-folders of the knossos hierarchy
source_format='wkwrap'; % Set to either 'wkwrap' for new data format, or 'wkcube' for the older data format
% If you entered 'wkcube' in the line above you do need to set this next line accordingly
% Not relevant for 'wkw'
experiment_name='could_be_anything_for_wkw'; %must be the exact phrase within every .raw file (phrase before _x0000_y0000_z0001.raw) 
% Destination of the data
destination_path='/camp/project/proj-emschaefer/working/processed/CLEM_GCaMP_180122/C408/10-exportEMtoAmira/0-images/'; %the big .raw file for Amira will be written into this folder
experiment_new_name='C408_aligned_matlab'; %new name for the .raw file (ex: 'file' if we want 'file.raw')
% These next 5 lines are just convenice so that you know what to enter as resolution in Amira
% Apparently you calculated this in your head. Also fine ;)
x_resolution=64; %resolution in nm    % this and next 3 lines are irrelevant in this script, scale will need to be added later in amira.
y_resolution=64; %resolution in nm
z_resolution=128; %resolution in nm
magnification_level=4; % magnification of used dataset
disp(['resolution (nm): x=' num2str(x_resolution*magnification_level) ' y=' num2str(y_resolution*magnification_level) ' z=' num2str(z_resolution*magnification_level)])

%% SECTION 2
% Added utility function to the auxiliaryMethods repo
boundaries = Util.approximateDatasetBoundingBox(source_path);
disp(['boundaries (vx): x=' num2str(boundaries(1,:)) ' y=' num2str(boundaries(2,:)) ' z=' num2str(boundaries(3,:))])

%% SECTION 3
% This should now work with both data format (wkw and wkcube)
disp('reading webKnossos structure...')
p.backend = source_format;
p.root = source_path;
if strcmp(p.backend, 'wkcube')
    p.prefix = experiment_name;
end
stack = loadRawData(p, boundaries);
disp('reading finished')

%% SECTION 4
% Write it into one big .raw file:
disp(' writing Amira-readable file... ')
fid=fopen([destination_path '/' experiment_new_name '.raw'],'w');
fwrite(fid,stack,'uint8');
fclose(fid);
disp(['finished writing ' num2str(destination_path) '/' num2str(experiment_new_name) '.raw'])

%load stack in Amira (drag & drop *.raw datei), boundaries and reoslution printed to matlab prompt should be used for import 

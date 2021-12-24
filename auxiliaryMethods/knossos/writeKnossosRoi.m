function  writeKnossosRoi( kl_parfolder, kl_fileprefix, kl_roiStart, ...
    kl_data, classT, kl_filesuffix, options, cubesize )
% WRITEKNOSSOSROI(KL_PARFOLDER, KL_FILEPREFIX, KL_ROISTART, KL_DATA):
%   Write large data from Malab into multiple .raw files by
%   giving the start coordinates of the cube. The precision used is an
%   unsigned integer with 8 bits.
%
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory where you want the files to be
%           saved as a string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name with which you want the files to be saved without
%           the coordinates or the ending as a string, e.g.0 '100527_k0563_mag1'
%       KL_ROISTART: Give an array of 3 numbers of the pixel coordinates of the
%           start of your region of interest, no need for the full four digits:
%           0020 -> 20. E.g. [21 30 150]
%       KL_DATA: Give the name of the matrix containing the data as given in
%           the Matlab Workspace.
%       options: (Optional) struct
%           Optional flags are
%           'noRead': Prevent reading from existing cubes before writing.
%           'check0cube': Only write if cube contains non-zero elements.
%           'mergePendantic': Cube is only overwritten if no (non-zero)
%               data is replaced.
%
%
%   => writeKnossosRoi( �E:\e_k0563\k0563_mag1', �100527_k0563_mag1�, [21 30 150], ans )
%
% WRITEKNOSSOSROI(KL_PARFOLDER, KL_FILEPREFIX, KL_ROISTART, KL_DATA, CLASST): %
%   The function has the following arguments:
%       CLASST: paramter specifying a class type to save the data as eg.
%       'uint8' (standard) or 'single'

if ~exist('classT','var') || isempty(classT)
    classT = 'uint8';
end
if ~exist('kl_filesuffix','var') || isempty(kl_filesuffix)
    kl_filesuffix = '';
end
if ~exist('options','var') || isempty(options)
    options = '';
end
if ~exist('cubesize','var') || isempty(cubesize)
    cubesize = [128 128 128 1];
end
if iscolumn(cubesize)
    cubesize = cubesize';
end
cubesize(end+1:4) = 1;
if size(kl_data, 4) ~= cubesize(4)
    error('Specified data has not the specified number of channels.');
end

% Calculate the cube's size in pixels and xyz-coordinates
data_size = size( kl_data );
data_size(end+1:4) = 1;
kl_bbox = [kl_roiStart; kl_roiStart + data_size(1:3) - 1]';

kl_bbox_cubeind = [floor( ( kl_bbox(:,1) - 1 )./cubesize(1:3)'), ...
                   ceil( kl_bbox(:,2)./cubesize(1:3)' ) - 1];

% Read every cube touched with readKnossosCube, substitute the
% overlapping parts and then write the whole cube with writeKnossosCube
for kl_cx = kl_bbox_cubeind(1,1) : kl_bbox_cubeind(1,2)
    for kl_cy = kl_bbox_cubeind(2,1) : kl_bbox_cubeind(2,2)
        for kl_cz = kl_bbox_cubeind(3,1) : kl_bbox_cubeind(3,2)

            kl_thiscube_coords = bsxfun(@times, ...
                [[kl_cx; kl_cy; kl_cz],[kl_cx; kl_cy; kl_cz]+1], ...
                cubesize(1:3)');
            kl_thiscube_coords(:,1) = kl_thiscube_coords(:,1) + 1;
            
            kl_validbbox = [max( kl_thiscube_coords(:,1), kl_bbox(:,1) ),...
                min( kl_thiscube_coords(:,2), kl_bbox(:,2) )];
            
            % Check if we want to over-write the entire cube. If this
            % is indeed the case, then we do not need to read the old
            % values from disk.
            kl_no_read = all(kl_validbbox(:) == kl_thiscube_coords(:));
            
            kl_validbbox_cube = kl_validbbox - ...
                repmat( kl_thiscube_coords(:,1), [1 2] ) + 1;
            kl_validbbox_roi = kl_validbbox - ...
                repmat( kl_bbox(:,1), [1 2] ) + 1;
            
            if kl_no_read || strcmp(options, 'noRead')
                kl_cube = zeros(cubesize, classT);
            else
                kl_cube = readKnossosCube( kl_parfolder, kl_fileprefix, ...
                    [kl_cx, kl_cy, kl_cz], [classT '=>' classT], ...
                    kl_filesuffix, 'raw', cubesize);
            end
            
            kl_cube( kl_validbbox_cube(1,1) : kl_validbbox_cube(1,2),...
                kl_validbbox_cube(2,1) : kl_validbbox_cube(2,2),...
                kl_validbbox_cube(3,1) : kl_validbbox_cube(3,2), : ) =...
                kl_data( kl_validbbox_roi(1,1) : kl_validbbox_roi(1,2),...
                kl_validbbox_roi(2,1) : kl_validbbox_roi(2,2),...
                kl_validbbox_roi(3,1) : kl_validbbox_roi(3,2), : );
            
            writeKnossosCube( kl_parfolder, kl_fileprefix, ...
                [kl_cx, kl_cy, kl_cz], kl_cube, classT, kl_filesuffix, ...
                options, cubesize);
        end
    end
end
end

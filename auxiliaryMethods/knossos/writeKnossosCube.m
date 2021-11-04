function writeKnossosCube( kl_parfolder, kl_fileprefix, kl_cubeCoord, ...
    kl_cube, classT, kl_filesuffix, options, cubesize )
% WRITEKNOSSOSCUBE: Write from Matlab into raw data
%
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory where you want the file to be
%           saved as a string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name with which you want the file to be saved without
%           the coordinates or the ending as a string, e.g. '100527_k0563_mag1'
%       KL_CUBECOORD: Give an array of 3 numbers of the xyz-coordinates of
%           the location of the cube, no need for the full four digits:
%           0020 -> 20. E.g. [21 30 150]
%       KL_CUBE: Give the name of the 128x128x128 matrix containing the data as
%           given in the Matlab Workspace.
%       options: (Optional) struct
%           Optional flags are
%           'mergePendantic': Cube is only overwritten if no (non-zero)
%               data is replaced.
%
%   => writeKnossosCube( �E:\e_k0563\k0563_mag1', �100527_k0563_mag1�, [21 30 150], ans )

if ~exist('classT','var') || isempty(classT)
    classT = 'uint8';
end
if ~isa(kl_cube, classT)
    error('Input data type does not match the specified data type.');
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

% Building the name of the directory, where the file is to be saved
kl_fullfolder = fullfile( kl_parfolder, ...
    sprintf( 'x%04.0f', kl_cubeCoord(1) ),...
    sprintf( 'y%04.0f', kl_cubeCoord(2) ), ...
    sprintf( 'z%04.0f', kl_cubeCoord(3) ) );
kl_file = sprintf( '%s_x%04.0f_y%04.0f_z%04.0f%s.raw',...
    kl_fileprefix, kl_cubeCoord, kl_filesuffix );

% Building the full filename
kl_fullfile = fullfile( kl_fullfolder, kl_file );

% Check if we're only writing zeros. If yes, then just delete the
% cube completely. The readKnossosCube function will automatically
% fill in zero values.
if ~any(kl_cube(:))
    if exist(kl_fullfile, 'file')
        warning('Removing all-zero cube');
        delete(kl_fullfile);
    end
    return;
end

% If the directory does not exist, build it
if ~exist( kl_fullfolder, 'dir' )
    mkdir( kl_fullfolder );
end

% If the file exsits and the option 'mergePedantic' is passed check
% whether we are not canceling data
if( exist( kl_fullfile, 'file' ) && strcmp(options, 'mergePendantic'))
    fid = -1;
    while fid < 0
        fid = fopen( kl_fullfile );
        pause(2);
    end
    kl_cube_before = fread( fid, classT );
    kl_cube_before = reshape( kl_cube_before, cubesize );
    temp = (kl_cube_before ~= 0) .* (kl_cube ~= 0);
    if sum(temp(:)) == 0
        kl_cube = kl_cube + kl_cube_before;
        fwrite( fid, kl_cube(:), classT );
        fclose( fid );
    else
        fclose( fid );
        error('Error: You are trying to replace existing values');
    end
else
    % Create the file and write in it
    fid = fopen( kl_fullfile, 'w+' );
    fwrite( fid, kl_cube(:), classT );
    fclose( fid );
end

end

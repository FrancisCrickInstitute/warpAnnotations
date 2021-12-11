function [kl_cube, cube_exist] = readKnossosCube( kl_parfolder, kl_fileprefix, ...
    kl_cubeCoord, classT, kl_filesuffix, ending, cubesize, returnZeros)
% READKNOSSOSCUBE: Read raw data from EM into Matlab
%
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory of the data you want to read as a
%           string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name of the specific file you want to read without
%           the coordinates or the ending as a string, e.g. '100527_k0563_mag1'
%       KL_CUBECOORD: Give an array of 3 numbers of the xyz-coordinates as
%           given in the file name, no need for the full four digits: 0020 ->
%           20. E.g. [21 30 150]
%       CLASST: Optional! Standard version is unsigned int with 8 bits. For the
%           precision of the values.
%       cubesize: [1xN] int
%           Size of a knossos-cube.
%           (Default [128, 128, 128, 1])
%       returnZeros: (Optional) logical
%           Flag indicating that zeros should be returned if the cube does
%           not exist. Otherwise [] is returned.
%           (Default: true)
%
%   => readKnossosCube( �E:\e_k0563\k_0563_mag1', �100527_k0563_mag1�, [21 30 150], �uint8� )
%

if ~exist('classT','var') || isempty(classT)
    classT = 'uint8=>uint8';
end
if ~exist('ending','var') || isempty(ending)
    ending = 'raw';
end
if ~exist('kl_filesuffix','var') || isempty(kl_filesuffix)
    kl_filesuffix = '';
end
if ~exist('cubesize','var') || isempty(cubesize)
    cubesize = [128 128 128];
elseif numel(cubesize) == 1
    cubesize = repmat(cubesize,1,3);
end
if ~exist('returnZeros','var') || isempty(returnZeros)
    returnZeros = true;
end

% Building the full filename
kl_fullfile = fullfile( kl_parfolder, sprintf( 'x%04.0f', kl_cubeCoord(1) ),...
    sprintf( 'y%04.0f', kl_cubeCoord(2) ), sprintf( 'z%04.0f', kl_cubeCoord(3) ),...
    sprintf( ['%s_x%04.0f_y%04.0f_z%04.0f%s.' ending], kl_fileprefix, kl_cubeCoord, kl_filesuffix ) );

% If this file exists, load it into Matlab, else fill the matrix with zeros
if( exist( kl_fullfile, 'file' ) )
    cube_exist = 1;
    if( strcmp( ending, 'raw' ) )
        fid = fopen( kl_fullfile );
        kl_cube = fread( fid, classT);
        try
            kl_cube = reshape( kl_cube, cubesize);
        catch
            %this circumvents a webknossos bug that omits planes consisting
            %of zeros only at the end of the cube
            warning('auxiliaryMethods:readKnossosCube', ...
                ['Could not reshape the raw file to fit the ' ...
                'cubesize. Filling it up using linear indices.']);
            tmp = zeros(cubesize, 'like', kl_cube);
            tmp(1:length(kl_cube)) = kl_cube;
            kl_cube = tmp;
        end
        fclose( fid );
    else
        load( kl_fullfile );
        if ~exist( 'kl_cube', 'var' )
            kl_cube = kl_stack;
        end
    end
else
    cube_exist = 0;
    warning('auxiliaryMethods:readKnossosCube', ...
        'Attempting to read from cube that does not exist');
    if returnZeros
        classT2=bsxfun(@eq,classT,'>');
        classT2=classT(find(classT2)+1:end);
        kl_cube = zeros( cubesize, classT2 );
    else
        kl_cube = [];
    end
end
end

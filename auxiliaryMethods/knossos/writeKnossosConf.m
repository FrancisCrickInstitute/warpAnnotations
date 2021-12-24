function writeKnossosConf( savePath, expName, boundary, scale, ...
    magnification, classT, cubesize, prefix)
%writeKnossosConf( savePath, expName, boundary, scale, magnification, cubesize )
%   Write KNOSSOS configuration file
% Author: Manuel Berning <manuel.berning@brain.mpg.de>
% Modified by Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%default arguments
if ~exist('classT', 'var') || isempty(classT)
    classT = 'uint8';
end
if ~exist('cubesize', 'var') || isempty(cubesize)
    cubesize = [128 128 128 1];
end
cubesize(end+1:4) = 1; %channels if not defined
if ~exist('prefix', 'var') || isempty(prefix)
    prefix = '';
end


%write file
fid = fopen(fullfile(savePath, 'knossos.conf'), 'w');
if fid==-1
    warning(['Could not write ' fullfile(savePath, 'knossos.conf')])
else
    fprintf(fid, 'experiment name "%s";\n', expName);
    fprintf(fid, 'boundary x %i;\n', boundary(1));
    fprintf(fid, 'boundary y %i;\n', boundary(2));
    fprintf(fid, 'boundary z %i;\n', boundary(3));
    fprintf(fid, 'scale x %4.2f;\n', scale(1));
    fprintf(fid, 'scale y %4.2f;\n', scale(2));
    fprintf(fid, 'scale z %4.2f;\n', scale(3));
    fprintf(fid, 'magnification %i;\n', magnification);
    fprintf(fid, 'cubesize x %4.2f;\n', cubesize(1));
    fprintf(fid, 'cubesize y %4.2f;\n', cubesize(2));
    fprintf(fid, 'cubesize z %4.2f;\n', cubesize(3));
    fprintf(fid, 'cubesize c %4.2f;\n', cubesize(4)); %channels
    fprintf(fid, 'root %s;\n', savePath);
    fprintf(fid, 'prefix %s;\n', prefix);
    fprintf(fid, 'classT %s;\n', classT);
    fclose(fid);
end
end
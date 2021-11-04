function writeKnossosConf(obj, voxelSize, mag, boundary)
%Write the knossos.conf file for the current data.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('boundary', 'var') || isempty(boundary)
    boundary = obj.getBbox();
    boundary = boundary(:,2);
end
outfile = fullfile(obj.root, 'knossos.conf');
if ~exist(outfile, 'file')
    fid = fopen(outfile, 'w');
else
    error('%s already exists.', outfile);
end
try
    fprintf(fid, ['experiment name "%s"; \n', ...
        'boundary x %d;\n', ...
        'boundary y %d;\n', ...
        'boundary z %d;\n', ...
        'scale x %.4f;\n', ...
        'scale y %.4f;\n', ...
        'scale z %.4f;\n', ...
        '\n', ...
        'magnification %d;'], obj.prefix, boundary(1), ...
        boundary(2), boundary(3), voxelSize(1), ...
        voxelSize(2), voxelSize(3), mag);
catch err
    fclose(fid);
    rethrow(err);
end
end
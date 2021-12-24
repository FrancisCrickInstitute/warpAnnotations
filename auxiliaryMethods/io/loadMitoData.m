function data = loadMitoData(root, prefix, box)
    % data = loadMitoData(root, prefix, box)
    %   Load output data from Benedikt's mitochondria CNN.
    %
    % root
    %   String (with trailing slash). Root directory, which
    %   contains the KNOSSOS entire hierarchy.
    %
    % prefix
    %   String. Prefix of the files containing the CNN output.
    %
    % box
    %   3x2 matrix. The two points specified by the columns of
    %   'box' delimit the bounding box for which to load data.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % load data from cubes
    data = readKnossosRoi( ...
        root, prefix, box, 'single', '', 'raw', 3);
    
    % three channels
    %   1 → membrane
    %   2 → vesicles
    %   3 → mitochondria
    data = data(:, :, :, 3);
end

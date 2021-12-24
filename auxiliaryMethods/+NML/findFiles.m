function nmlFiles = findFiles(rootDir)
    % nmlFiles = findFiles(rootDir)
    %   Returns a list of all NML files contained in the
    %   specified directory.
    %
    % rootDir
    %   Path of the directory, which will be scanned.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    files = dir(rootDir);
    fileNames = {files.name};
    
    % get file extensions
    [~, ~, fileExts] = cellfun( ...
        @fileparts, fileNames, ...
        'UniformOutput', false);
    
    % filter by file extension
    isNml = strcmp('.nml', fileExts);
    nmlFiles = fileNames(isNml);
end

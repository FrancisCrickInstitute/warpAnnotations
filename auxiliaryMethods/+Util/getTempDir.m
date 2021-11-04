function tempDir = getTempDir()
    % tempDir = getTempDir()
    %   Gets the path to the directory of temporary files.
    %   On GABA, it uses the scratch directory.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % default
    tempDir = tempdir();
    
    % use default if not UNIX
    if ~isunix; return; end
 
    % Get hostname of current server
    [code, host] = runShell('hostname');
    
    % check for GABA
    if ~code && strncmpi(host, 'gaba', 4)
        tempDir = ['/tmpscratch/', getenv('USER'), '/'];
    end

    % check whether running on Crick infrastructure
    if ~code && contains(host, 'camp.thecrick.org') 
        tempDir = ['/home/camp/', getenv('USER'), '/work/temp/'];
    end

end

function hash = getGitHash(dir)
    % hash = getGitHash()
    %   Get hash of current git commit.
    %
    % hash = getGitHash(dir)
    %   Get hash of git repository in specified directory.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    %   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    
    if exist('dir', 'var') && ~isempty(dir)
        prevDir = pwd();
        cd(dir);
    else
        prevDir = [];
    end

    % run git
    [status, hash] = ...
        system('git rev-parse HEAD');
    
    % to to original dir (before the assertion can cause an error)
    if ~isempty(prevDir)
        cd(prevDir);
    end
    
    % check exit code
    assert(not(status));
    
    % remove excess white spaces
    hash = strtrim(hash);
    
end
function skel = setDescriptionFromRunInfo(skel, runInfo)
    % skel = setDescriptionFromRunInfo(skel, runInfo)
    %   Sets the skeleton's description based on the `runInfo` struct
    %   generated using `Util.runInfo`.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    skel = skel.setDescription(sprintf( ...
        '%s (%s)', runInfo.filename, runInfo.git_repos{1}.hash));
end

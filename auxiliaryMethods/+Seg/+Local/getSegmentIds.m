function segIds = getSegmentIds(pCube)
    % GETSEGMENTIDS
    %   Builds a vector with the global IDs of all segments
    %   contained in the specified cube.
    %
    % pCube
    %   Parameters for a segmentation cube
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % load segments file
    load(pCube.segmentFile, 'segments');
    
    % build vector with global segment ids
    segIds = [segments.Id];
end


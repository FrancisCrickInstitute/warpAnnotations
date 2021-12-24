function okay = checkBoundingBox(bbox)
    % okay = checkBoundingBox(bbox)
    %   Checks (and returns true) if `bbox` is a valid
    %   bounding box.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    %
    
    okay = ...
        ismatrix(bbox) ...
      & all(size(bbox) == [3, 2]) ...
      & all(bbox(:, 1) <= bbox(:, 2));
  
    % NOTE
    %   Note sure whether we should also check that
    %   all coordinates are positive.
end

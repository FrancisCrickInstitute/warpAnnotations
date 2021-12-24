function isAbove = isMaxPdistAbove(points, minDist)
    % isAbove = isMaxPdistAbove(points, minDist)
    %   Returns a logical which indicates whether any of the pairwise
    %   distances between the specified `points` is above `minDist`. This
    %   is a more efficient variant of `max(pdist(points)) > minDist`.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    isAbove = false;
    
    % enough points for form pairs?
    if size(points, 1) < 2; return; end
    
    %
    pointsBox = [ ...
        min(points, [], 1); ...
        max(points, [], 1)];
    pointsDiff = diff(pointsBox);
    % check if bbox is greater minDist
    isAbove = any(pointsDiff > minDist); 
    if isAbove; return; end;
    
    % do the precise calculation, but use only the points from convex hull
    % to make it faster. the try is necessary for coplanar points or < 3
    % points
%     try
%         points = convhull(points(:,1),points(:,2),points(:,3));
%     end
    if verLessThan('matlab','9.0')
        maxDist = pdist(points);
        maxDist = max(maxDist);
    else
        maxDist = pdist(points, 'squaredeuclidean');
        maxDist = sqrt(max(maxDist));
    end

    isAbove = maxDist > minDist;
end
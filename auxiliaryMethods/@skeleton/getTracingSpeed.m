function speed = getTracingSpeed(obj,treeIndices,limit_time)
%   INPUT treeIndices:(Optional) Vector of integer specifying the
%   trees of interest.

    if nargin < 3
        limit_time=60;
    end
    
    if nargin < 2
	treeIndices = 1:length(obj.nodes);
    end
    
	%Compute tracing speed of a tree in skeleton in 'mm per hour'
    for tr = 1:length(treeIndices)
        idx = treeIndices(tr);
        time(tr) = obj.measureTime(idx,limit_time);
        pathLength(tr) = obj.pathLength(idx);
    end
    totalTime = sum(time);
    totalPathLength = sum(pathLength);
    speed = (totalPathLength./1e6)/(totalTime./3600);
    
end

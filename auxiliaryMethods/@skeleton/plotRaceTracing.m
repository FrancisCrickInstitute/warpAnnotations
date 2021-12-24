function plotRaceTracing(obj)
%Plot all trees separately with color corresponding to the
%relative time between start and end of all tree annotations.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

annTimes = cellfun(@(x)x(:,8),obj.nodesNumDataAll, ...
    'UniformOutput',false);
%relative to first node
annTimes = cellfun(@(x)x-min(x(:)),annTimes,...
    'UniformOutput',false);
%ms to min
annTimes = cellfun(@(x)x./(1000*60),annTimes, ...
    'UniformOutput',false);

for tr = 1:obj.numTrees()
    trNodes = obj.nodes{tr}(:,1:3);
    trNodes = bsxfun(@times,trNodes,obj.scale);
    surf([trNodes(:,1)';trNodes(:,1)'], ...
        [trNodes(:,2)';trNodes(:,2)'], ...
        [trNodes(:,3)';trNodes(:,3)'], ...
        [annTimes{tr}';annTimes{tr}'], ...
        'facecol', 'no', 'edgecol', 'interp');
    hold on
end
colorbar
end
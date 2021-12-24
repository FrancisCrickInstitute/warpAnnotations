function borderMeta = borderMeta( p, noArea )
%BORDERMETA Calculate the border meta file for a segmentation run.
% INPUT p: struct
%           Segmentation parameter struct.
%       noArea: (Optional) logical
%           Flag to skip area calculation.
%           (Default: false)
% OUTPUT borderMeta: struct
%           Border meta struct.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

cluster = Cluster.config( ...
    'memory', 12, ...
    'time', '3:00:00', ...
    'taskConcurrency', 200, ...
    'priority', 75);

[borderSize, borderCoM, borderBbox] = ...
    Seg.Global.getGlobalBorderAreaAndCoM(p);
borderMeta.borderSize = borderSize;
borderMeta.borderCoM = borderCoM;
borderMeta.borderBbox = borderBbox;

if nargin > 1 && ~noArea
    [borderArea, borderArea2] = Seg.Global.physicalBorderAreas(p);
    borderMeta.borderArea = borderArea;
    borderMeta.borderArea2 = borderArea2;
end

end


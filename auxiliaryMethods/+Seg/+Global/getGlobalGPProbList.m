function prob = getGlobalGPProbList( p, segCubeIdx )
%GETGLOBALGPPROBLIST Load gp probabilities.
% INPUT p: Segmentation parameter struct.
%       segCubeIdx: (Optional) Integer vector of segmentation cube linear
%                   indices for which the edge list is loaded.
%                   (Default: All cubes in p.local)
% OUTPUT prob: [Nx1] array of single containing the GP probabilities.
%
% NOTE This does not take segment correspondences between local cubes into
%      account.
%
% see also: Seg.Global.getGlobalEdges
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('segCubeIdx','var') || isempty(segCubeIdx)
    segCubeIdx = 1:numel(p.local);
elseif iscolumn(segCubeIdx)
    segCubeIdx = segCubeIdx';
end

prob = cell(length(segCubeIdx),1);
for i = segCubeIdx
    if exist(p.local(i).probFile,'file')
        m = load(p.local(i).probFile);
        prob{i} = m.prob;
    else
       warning('File %s does not exist',p.local(i).probFile)
    end
end
prob = cell2mat(prob);

end

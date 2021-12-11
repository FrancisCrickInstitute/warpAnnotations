function skel = loadSkelCollectionFromSubfolders( folder, ...
    nodeOffset, toCellOutput )
%LOADSKELCOLLECTIONFROMSUBFOLDERS Loads all nml files that are in
% subfolders of the input folder. All skeletons in a subfolder will be
% merged. Into a single skeleton.
% INPUT folder: string
%           Path to base folder. All the subfolders in folder will be
%           scanned for nml-files.
%       nodeOffset: (Optional) double
%           Offset to the x, y and z coordinates of all nodes.
%           (Default: 1).
%       toCellOutput: (Optional) logical
%           Flag indicating that the output should be a cell array of
%           skeletons rather than a single skeleton object.
%           (Default: true)
% OUTPUT skel: skeleton object or [Nx1] cell of skeleton objects
%           The output skeleton either containing all nmls in a single
%           skeleton or all skeletons in a subfolder in a cell.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>


if ~exist('nodeOffset','var') || isempty(nodeOffset)
    nodeOffset = 1;
end

if ~exist('toCellOutput','var') || isempty(toCellOutput)
    toCellOutput = true;
end

subfolders = dir(folder);
subfolders = {subfolders([subfolders.isdir]).name};
subfolders = subfolders(3:end);

skel = cell(length(subfolders), 1);
for i = 1:length(subfolders)
    skel{i} = skeleton.loadSkelCollection( ...
        fullfile(folder, subfolders{i}), nodeOffset, false);
end

if ~toCellOutput
    tmp = skel{1};
    tmp.filename = '';
    for i = 2:length(skel)
        tmp = tmp.mergeSkels(skel{i});
    end
    skel = tmp;
end

end


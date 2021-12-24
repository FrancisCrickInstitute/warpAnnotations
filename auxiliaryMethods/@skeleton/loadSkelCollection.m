function [skel, treeOrigin] = loadSkelCollection(paths, nodeOffset, ...
    toCellOutput, addFilePrefix)
% Load a collection of nml-files.
% INPUT paths: cell array of strings or string
%           Cell array of nml-file paths (see also constructor)
%       	or string to path containing the root folder in which the nmls
%           are stored.
%       nodeOffset: (Optional) double
%           Offset to the x, y and z coordinates of all nodes.
%           (Default: 1).
%       toCellOutput: (Optional) logical
%           Flag indicating that the output should be a cell array of
%           skeletons rather than a single skeleton object.
%           (Default: false)
%       addFilePrefix: (Optional) logical
%           Flag to indicate that the name of the file is added as prefix
%           to each tree name. This corresponds to the behavior of WK when
%           opening multiple tracings.
%           (Default: false)
% OUTPUT skel: skeleton object or [Nx1] cell array of skeleton objects
%           A Skeleton object containing the trees of all
%           tracings. The first file in filenames will be
%           used to initialize the parameters for the output
%           Skeleton.
%           In case toCellOutput is true each tracings will be stored in a
%           separate skeleton object and a cell array of skeleton objects
%           is returned.
%        treeOrigin: table
%           Table containing the filename and tree idx
%           of the original file for each tree in skel. This
%           is useful to keep track to which tracing a tree
%           belongs.
%           If toCellOutput is set to true then this output is empty.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('nodeOffset','var') || isempty(nodeOffset)
    nodeOffset = 1;
end

if ~exist('toCellOutput','var') || isempty(toCellOutput)
    toCellOutput = false;
end

if ~exist('addFilePrefix','var') || isempty(addFilePrefix)
    addFilePrefix = false;
end

%get all nml-files in paths if path is string
if ischar(paths)
    paths = Util.addFilesep(paths);
    listing = dir([paths '*.nml']);
    names = {listing.name};
    if isempty(names)
        error('No nml files were found in %s.', paths);
    end
    paths = cellfun(@(x)strcat(paths,x),names, ...
        'UniformOutput',false);
end

if toCellOutput
    skel = cellfun(@(x)skeleton(x, false, nodeOffset), paths', ...
        'UniformOutput', false);
    treeOrigin = [];
else
    %initialize outputs
    skel = skeleton(paths{1}, true, nodeOffset);
    skel.filename = ''; %no associated filename
    treeOrigin = struct([]);

    for i = 1:length(paths)
        skel2 = skeleton(paths{i},false,nodeOffset);
        if addFilePrefix
            [~, fn, ~] = fileparts(paths{i});
            skel2.names = cellfun(@(x)sprintf('%s_%s', fn, x), ...
                skel2.names, 'uni', 0);
        end
        skel = skel.mergeSkels(skel2);
        for j = 1:skel2.numTrees()
            treeOrigin(end+1).filename = paths{i};
            treeOrigin(end).treeIdx = j;
        end
    end
    treeOrigin = struct2table(treeOrigin);
end
end
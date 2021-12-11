function createResolutionPyramid(inParam, bbox, outRoot, isSeg, voxelSize)
%Input:
%   If using just one input argument, and normal wK hierachy with JSONs
%   already present, rest inferred.
%   param = Parameter struct for mag1 KNOSSOS or WKW dataset
%   bbox = Bounding Box of KNOSSOS Hierachy mag1 
%       (minimal coordinates should align with start of Knossos cube (e.g. [1 1 1]))
%       (Not sure whether it will work if lower corner in bbox is not [1 1 1], NOT tested)
%   outRoot = where to write higher resolutions (subfolder named as the magnification will be created inside)
%   subsamplingSegmentation = if you try to subsample a segmentation (instead of raw data)
%       set this to true, will use @mode instead of @median for subsampling and some other tricks
%       THIS WILL REQUIRE MORE THAN 12GB of RAM with current settings (48GB works). Set your IndependentSubmitFunction!
%
% Written by
%   Manuel Berning <manuel.berning@brain.mpg.de>
%   Alessandro Motta <alessandro.motta@brain.mpg.de>

% The root directory specified in inParam might just be a symbolic link. It
% is thus possible, that the mag1 subdirectory is hidden. To avoid this,
% use readlink to resolve the symbolic link.
[~, inParam.root] = system(sprintf( ...
    'readlink -f "%s" < /dev/null', inParam.root));
inParam.root = strcat(strtrim(inParam.root), filesep);
assert(exist(inParam.root, 'dir') ~= 0);

% Read the datasource-properties.json
datasetDir = strcat(fileparts(fileparts(inParam.root(1:end-1))), filesep);
datasetProp = readJson(strcat(datasetDir, 'datasource-properties.json'));

if nargin < 5 || isempty(voxelSize)
    voxelSize = double([datasetProp.scale{:}]);
    Util.log('VoxelSize: %s.', mat2str(voxelSize));
end

if nargin < 4 || isempty(isSeg)
    isSeg = ~contains(inParam.root, 'color');
    Util.log('Segmentation flag: %s.', mat2str(isSeg));
end

if nargin < 3 || isempty(outRoot)
    outRoot = strcat(fileparts(inParam.root(1:end-1)),filesep);
    Util.log('Output is written to %s.', outRoot);
end

if nargin < 2 || isempty(bbox)
    boundingBox = datasetProp.dataLayers{1}.boundingBox;
    bbox(:,1) = [boundingBox.topLeft{:}];
    bbox(:,2) = [boundingBox.width, boundingBox.height, boundingBox.depth];
    assert(all(bbox(:) >= 0));
    bbox(:, 1) = bbox(:, 1) + 1;
    Util.log('Bbox was set to %s.', mat2str(bbox));
end
bbox = double(bbox);

if isSeg
    gbRamPerTask = 48;
    dtype = 'uint32';
else
    gbRamPerTask = 12;
    dtype = 'uint8';
end
if ~isfield(inParam, 'dtype')
    inParam.dtype = dtype;
end

% build parameters
outParam = inParam;
outParam.root = outRoot;

% Set according to memory limits, currently optimized for 12 GB RAM,
% segmentation will need 48 GB currently
% Will be paralellized on cubes of this size
cubeSize = [1024, 1024, 1024];

% Determine which magnifications to write
assert(voxelSize(1) == voxelSize(2));
magsToWrite = [1, 1, 1];

while magsToWrite(end, 3) < 512
    curVoxelSize = magsToWrite(end, :) .* voxelSize;
    if curVoxelSize(1) < curVoxelSize(3)
        curPoolVol = [2, 2, 1];
    else
        curPoolVol = [2, 2, 2];
    end

    magsToWrite(end + 1, :) = ...
        magsToWrite(end, :) .* curPoolVol; %#ok
    clear curVoxelSize curPoolVol;
end
% Remove `1-1-1` from list
magsToWrite(1, :) = [];

magGroups = {[1, 1, 1]};
for curIdx = 1:size(magsToWrite)
    curMag = magsToWrite(curIdx, :);
    if any(curMag ./ magGroups{end}(1, :) > 8)
        magGroups{end + 1} = vertcat( ...
            magGroups{end}(end, :), curMag); %#ok
    else
        magGroups{end} = vertcat( ...
            magGroups{end}, curMag);
    end
end

% Create output folder if it does not exist
if ~exist(outParam.root, 'dir')
    mkdir(outParam.root);
end

% Initialize wkw datasets
if isfield(outParam, 'backend') ...
        && strcmp(outParam.backend, 'wkwrap')
    allMagRoots = cellfun( ...
        @(magIds) sprintf('%d-%d-%d', magIds), ...
        num2cell(magsToWrite, 2), 'UniformOutput', false);
    allMagRoots = fullfile(outParam.root, allMagRoots);
    for i = 1:numel(allMagRoots)
        try
            wkwInit('new', allMagRoots{i}, 32, 32, outParam.dtype, 1);
        end
    end
    clear allMagRoots;
end

% Do the work, submitted to scheduler
curBbox = bbox;
curInParam = inParam;

for i = 1:numel(magGroups)
    X = unique([curBbox(1, 1):cubeSize(1):curBbox(1, 2), curBbox(1, 2)]);
    Y = unique([curBbox(2, 1):cubeSize(2):curBbox(2, 2), curBbox(2, 2)]);
    Z = unique([curBbox(3, 1):cubeSize(3):curBbox(3, 2), curBbox(3, 2)]);
    
    idx = 1;
    inputCell = cell(prod(cellfun(@numel, {X, Y, Z}) - 1), 1);
    
    for x = 1:(numel(X) - 1)
        for y = 1:(numel(Y) - 1)
            for z = 1:(numel(Z) - 1)
                thisBBox = [ ...
                    X(x), (X(x + 1) - 1);
                    Y(y), (Y(y + 1) - 1);
                    Z(z), (Z(z + 1) - 1)];
                inputCell{idx} = {thisBBox};
                idx = idx + 1;
            end
        end
    end
    
    job = Cluster.startJob( ...
        @writeSupercubes, inputCell, ...
        'sharedInputs', {curInParam, magGroups{i}, outParam, isSeg}, ...
        'sharedInputsLocation', [1, 3:5], ...
        'cluster', { ...
            'time', '8:00:00', ...
            'memory', gbRamPerTask, ...
            'taskConcurrency', 100}, ...
        'name', 'supercubes');
    Cluster.waitForJob(job);
    
    % Update bounding box
    curMag = magGroups{i}(end, :);
    curBbox = ceil(bsxfun(@rdivide, bbox - 1, curMag(:))) + 1;
    
    % Update root path
    curInParam.root = fullfile( ...
        outParam.root, sprintf('%d-%d-%d', curMag));
    curInParam.root(end + 1) = filesep;
    
    % Update prefix
    if isfield(curInParam, 'prefix')
        curInParam.prefix = regexprep( ...
            curInParam.prefix, '(\d+)$', num2str(curMag));
    end
end

end

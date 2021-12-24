function [borderSize, borderCoM, borderBbox] = ...
    getGlobalBorderAreaAndCoM( p, cluster )
%GETGLOBALBORDERAREAANDCOM Load the border area and center of mass for all
% edges.
% INPUT p: struct
%           Segmentation parameter struct
%       cluster: (Optional) parallel.cluster object
%           Cluster object for parallel calculation
%           (Default: sequential calculation)
% OUTPUT borderSize: [Nx1] int
%           Border size in number of voxels for each border.
%        borderCom: [Nx3] int
%           Center of mass for each border.
%        borderBbox: [Nx6] int
%           Bounding box for each border
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if exist('cluster', 'var') && ~isempty(cluster)
    Util.log('Submitting job to cluster.')
    inputCell = cell(numel(p.local), 1);
    inputCell = arrayfun(@(i){p.saveFolder, i}, 1:numel(p.local),'uni',0);
    job = Cluster.startJob(@jobWrapper, inputCell, 'numOutputs', 3, ...
        'cluster', cluster, 'name', 'borderProps');
    Util.log('Waiting for job %d output.', job.Id);
    wait(job);
    Util.log('Fetching job %d output.', job.Id);
    out = fetchOutputs(job);
    borderSize = out(:,1);
    borderCoM = out(:,2);
    borderBbox = out(:,3);
else
    borderSize = cell(numel(p.local),1);
    borderCoM = cell(numel(p.local),1);
    borderBbox = cell(numel(p.local),1);
    for i = 1:numel(p.local)
        [borderSize{i}, borderCoM{i}, borderBbox{i}] = jobWrapper(p.local(i));
    end
end

borderSize = cell2mat(borderSize);
borderCoM = cell2mat(borderCoM);
if nargout > 2
    borderBbox = cell2mat(borderBbox);
end

end

function [area, com, bbox] = jobWrapper(varargin)
% Usage
%   jobWrapper(pCube) - call the job wrapper directly using the parameter
%       struct for a local segmentation cube, e.g.. jobWraper(p.local(1))
%   jobWrapper(paramFile, i) - call the job wrapper with the path to the
%       segmentation parameter file and the current local segmentaiton
%       cube, e.g. jobWrapper(p.saveFolder, 1)

if length(varargin) == 1 % the local cube struct
    pCube = varargin{1};
elseif length(varargin) == 2
    m = load(fullfile(varargin{1}, 'allParameter.mat'));
    pCube = m.p.local(varargin{2});
end

m = load(pCube.borderFile);
m.borders = m.borders(:);
if ~isempty(m.borders)
    area = uint32([m.borders.Area]');
    com = vertcat(m.borders.Centroid);
    com = uint16(bsxfun(@plus,com, ...
        pCube.bboxSmall(:,1)' - 1));
    if nargout > 2
        % convert to subscripts (faster than direct cellfun)
        l = [m.borders.Area];
        l = l(:);
        tmp = {m.borders.PixelIdxList};
        tmp = tmp(:);
        tmp = cellfun(@(x)x(:), tmp, 'uni', false);
        tmp = Util.indConversion(pCube.bboxSmall, cell2mat(tmp));
        tmp = mat2cell(tmp, l, 3);

        bbox = cell2mat(cellfun(@calcBbox, tmp, 'uni', false));
    end
else % necessary, otherwise cell2mat does not work
    area = uint32([]);
    com = uint16([]);
    bbox = uint16([]);
end
end

function bbox = calcBbox(coords)
bbox = uint16([min(coords, [], 1), max(coords, [], 1)]);
end

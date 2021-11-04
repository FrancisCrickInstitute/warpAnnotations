function [ coms, coms_global ] = borderCoM( varargin )
%BORDERCOM Get the border CoMs for a local cube.
% USAGE
%       [coms, coms_global] = Seg.Local.borderCoM(pCube)
%           Load the borders using the parameter struct for a local
%           segmentation cube, i.e. use pCube = p.local(i).
%       coms = Seg.Local.borderCoM(borders)
%           Load the border CoMs using the border struct.
%       [coms, coms_global] = Seg.Local.borderCoM(borders, bbox)
%           Load the border CoMs using the border struct and the bounding
%           box of the local segmentation cube to get the global
%           coordinates.
%
% OUTPUT coms: [Nx3] int
%           The border coms in local cube coordinates (rounded to int).
%        coms_global: [Nx3] int
%           The border coms in global coordinates (rounded to int).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

% parse inputs
if length(varargin) == 1
    assert(isstruct(varargin{1}));
    if isfield(varargin{1}, 'borderFile')
        % pCube case
        m = load(varargin{1}.borderFile);
        borders = m.borders;
        bbox = varargin{1}.bboxSmall;
    else
        % borders only case
        borders = varargin{1};
        bbox = [];
    end
elseif length(varargin) == 2
    borders = varargin{1};
    bbox = varargin{2};
else
    error('Too many input parameters.');
end

% get coms
coms = round(reshape([borders.Centroid], 3, [])');

if nargout > 1 && ~isempty(bbox)
    coms_global = bsxfun(@plus, coms, bbox(:,1)' - 1);
end

end


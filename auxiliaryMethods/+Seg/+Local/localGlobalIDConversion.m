function [ varargout ] = localGlobalIDConversion( mode, convInfo, varargin )
%LOCALGLOBALIDCONVERSION Convert bewteen local and global segmentation ids.
% INPUT mode: Conversion mode 'GlobalToLocal' or 'LocalToGlobal' (or 'l2g', 
%           'g2l')
%       convInfo: Either a struct from p.local or a cell array containing
%           localIds in the first and globalIds in the second cell.
%       varargin: An arbitrary number of arrays with indices
% OUTPUT varargout: Varargin arrays with converted indices.
%
% NOTE Directly using the localIds and globalIds input case does not
%      require loading the localToGlobalSegID.mat file for every function
%      call and might thus be faster in some cases.
% NOTE This function should only be used if all local and global indices
%      belong to the same local segmentation cube since no checks on the
%      indices are performed.
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if isstruct(convInfo)
    m = load([convInfo.saveFolder 'localToGlobalSegId.mat']);
    localIds = m.localIds;
    globalIds = m.globalIds;
else
    localIds = convInfo{1};
    globalIds = convInfo{2};
end

%delete zero entry
localIds = localIds(2:end);
globalIds = globalIds(2:end);

%create mapping
switch mode
case {'GlobalToLocal','g2l','G2L'}
        mapping = sparse(double(globalIds), 1, double(localIds));
        dtype = class(localIds);
    case {'LocalToGlobal','l2g','L2G'}
        mapping = sparse(double(localIds), 1, double(globalIds) );
        dtype = class(globalIds);
    otherwise
        error('Conversion mode %s not implemented', mode);
end

%apply mapping to inputs
varargout = cell(length(varargin),1);
for i = 1:length(varargin)
    varargout{i} = cast(varargin{i},dtype);
    varargout{i}(varargin{i} > 0) = full(mapping(varargin{i}(varargin{i} > 0)));
end


end

function [correspondences, corr_coms] = getGlobalCorrespondences(p)
%GETGLOBALCORRESPONDENCES Loads all correspondence data files and merges them
%into a single global matrix
%   correspondences = LOADCORRESPONDENCES(param)
%
%   INPUT
%     param: global parameter array (e.g. from setParameterSettingsBig.m)
%
%   OUTPUT
%     correspondences: (k x 2), uint32
%     corr_coms: (k x 3), double

%   Author: Thomas Kipf <thomas.kipf@brain.mpg.de>
%   Modified by: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
%
% see also calculateGlobalCorrespondences
%--------------------------------------------------------------------------

  correspondences = zeros(2, 0);
  corr_coms = zeros(3, 0); 

  % Collect all global correspondences
  files = dir([p.correspondence.saveFolder, '*.mat']);
  warning('off', 'all'); % when com does not exist in files
  for i = 1:length(files)
    m = load([p.correspondence.saveFolder files(i).name], ...
        'uniqueCorrespondences', 'com');
    correspondences = [correspondences, m.uniqueCorrespondences'];
    if isfield(m, 'com')
        corr_coms = [corr_coms, m.com'];
    end
  end
  warning('on', 'all');
  correspondences = correspondences';
  corr_coms = corr_coms';
end

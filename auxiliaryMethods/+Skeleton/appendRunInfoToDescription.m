function skel = appendRunInfoToDescription(skel, info)
%APPENDRUNINFOTODESCRIPTION Append a run info string to the skeleton
% desription.
%
% INPUT skel: skeleton object
%       info: struct
%           see output of Util.runInfo()
%
% OUTPUT skel: skeleton object
%           The updated skeleton object with the run info appended to the
%           description.
%
% see also Util.formatRunInfoForSkel
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

skel = skel.setDescription(Util.formatRunInfoForSkel(info), ...
    'append', true, 'no_formatting', true);

end


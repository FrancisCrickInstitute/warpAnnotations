function list = regexpdir( folder, expr, options )
%REGEXPDIR Content of directory matching a regular expression.
% INPUT folder: String specifying path to folder.
%       expr: A regular expression.
%           (see regexp).
%       options: (Optional) String containing which can contain the
%           following characters as options:
%           'd': Return directories only.
%           'f': Return the full path.
%           'i': Case insensitive regexp.
% OUTPUT list: [Nx1] cell array of files which match the expression.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('options','var') || isempty(options)
    options = '';
end

if exist(folder,'dir')
    content = dir(folder);
else
    fprintf('Folder %s does not exist.\n', folder);
    list = [];
    return;
end

content(1:2) = []; %remove '.' and '..'

if strfind(options,'d') > 0
    list = {content([content.isdir]).name}';
else
    list = {content.name}';
end

if strfind(options,'i')
    list(cellfun(@(x)isempty(x) || x~=1,regexpi(list,expr,'once'))) = [];
else
    list(cellfun(@(x)isempty(x) || x~=1,regexp(list,expr,'once'))) = [];
end


if strfind(options,'f') > 0
    list = cellfun(@(x)[Util.addFilesep(folder), x], list, ...
        'UniformOutput', false);
end
end


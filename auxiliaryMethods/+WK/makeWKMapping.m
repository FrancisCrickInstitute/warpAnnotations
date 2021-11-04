function makeWKMapping( components, name , folder )
%MAKEWKMAPPING Create a json file for a webknossos mapping.
% INPUT components: [Nx1] cell-array. Each an equivalence class of global
%           segment IDs that will be mapped to one color. If a equivalence
%           class start with zero it will be not have any color.
%       name: String specifying the mapping name (without .json extension).
%       folder: (Optional) string
%           The folder where the output file is saved.
%           (Default: '.')
% OUTPUT Mapping saved as 'name'.json in the current folder.

% remove components with single segments
% this is a hack to work around webKNOSSOS
if nargin < 3
    folder = '.';
end
componentSize = cellfun(@numel, components);
components = components(componentSize > 1);

% Getting an error from tojson if input is uint32 or single
components = cellfun(@double, components, 'uni', 0);

coMapping.name = name;
coMapping.classes = components;
coMapping.hideUnmappedIds = true;
writeJson(fullfile(folder, [name '.json']),coMapping); 

end

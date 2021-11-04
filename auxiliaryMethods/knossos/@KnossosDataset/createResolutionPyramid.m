function createResolutionPyramid(obj)
% CREATERESOLUTIONPYRAMID Wrapper to create resolution pyramid based on
% the section.json
% see also createResolutionPyramid
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

idx = strfind(obj.root, filesep);
topFolder = obj.root(1:idx(end-1));
if ~exist(fullfile(topFolder, 'section.json'), 'file')
    warning(['Section.json does not exist and will be ' ...
        'created with default settings.'])
    obj.writeSectionJson();
end
createResolutionPyramid(obj);
end
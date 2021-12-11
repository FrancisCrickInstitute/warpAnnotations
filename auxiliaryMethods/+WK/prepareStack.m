function prepareStack(varargin)
% This function transforms the output of the cubing or segmentation into a
% folder that can be copied to webKnossos (dataset main folder for cubing,
% "segmentation" folder for segmentation to be copied into dataset main folder).
% This also includes the creation of all necessary JSON files.
%
% Input: structure containing the fields "settingsJSON", "layerJSON" and
%        "sectionJSON". Each of these fields have fields according to parameters
% 	 that  should be set, such as "resolutions" for the section JSON. Default
%        parameters are used for unset properties
%        An additional field "folder" in the input structure defines where to find
%	 the cubing / segmentation data. This is also the output folder. Alternatively,
%        the folder can be given as second argument to the function.



switch nargin
    case {1,2}
        if isfield(varargin{1},'settings')
            settingsJSON = varargin{1}.settings;
        else
            settingsJSON = struct();
        end
        if isfield(varargin{1},'layer')
            layerJSON = varargin{1}.layer;
        else
            layerJSON = struct();
        end
        if isfield(varargin{1},'section')
            sectionJSON = varargin{1}.section;
        else
            sectionJSON = struct();
        end
        if isfield(varargin{1},'folder')
            folder = varargin{1}.folder;
        elseif nargin > 1 && ischar(varargin{2})
            folder = varargin{2};
        end
        if isfield(varargin{1},'movefolders')
            movefolders = varargin{1}.movefolders;
        else
            movefolders = 1;
        end
        if isfield(varargin{1},'domask')
            domask = varargin{1}.domask;
        else
            domask = 0;
        end
    case 3
        settingsJSON = varargin{1};
        layerJSON = varargin{2};
        sectionJSON = varargin{3};
    case 4
        settingsJSON = varargin{1};
        layerJSON = varargin{2};
        sectionJSON = varargin{3};
        folder = varargin{4};
    otherwise
        display('No input given, initializing standard JSONs!')
        settingsJSON = struct();
        layerJSON = struct();
        sectionJSON = struct();
end
% Where to write
if ~exist('folder','var')
    error('No folder given')
    display('No folder given, take current directory')
    folder = 'pwd';
end
if ~exist(folder,'dir')
    mkdir(folder);
end
% What we need to write to settings.json
if ~isfield(layerJSON,'typ') || strcmp(layerJSON.typ,'color')
    if ~isfield(settingsJSON,'name')
        display('No name given, initializing as "test"!')
        settingsJSON.name = 'test';
    end
    if ~isfield(settingsJSON,'priority')
        display('No priority given, initializing as "0"!')
        settingsJSON.priority = 0;
    end
    if ~isfield(settingsJSON,'scale')
        display('No scale given, initializing as "[11.24 11.24 28]"!')
        settingsJSON.scale = [11.24 11.24 28];
    end
end

% What we need to write to layer.json
if ~isfield(layerJSON,'typ')
    display('No typ given, initializing as "color"!')
    layerJSON.typ = 'color';
end
if ~isfield(layerJSON,'class')
    display('No class given, initializing as "uint8"!')
    layerJSON.class = 'uint8';
end

% What we need to write to section.json
if ~isfield(sectionJSON,'resolutions')
    display('No resolutions given, initializing as "[1]"!')
    sectionJSON.resolutions = 1;
end
if ~isfield(sectionJSON,'bbox')
    display('No bbox given, initializing as "[0 1000; 0 1000; 0 1000]"!')
    sectionJSON.bbox = [0 1000; 0 1000; 0 1000];
end

% Write files to folder hierachy
switch layerJSON.typ
    case 'color'
        subfolder1 = 'color';
        subfolder2 = subfolder1;
        
    case 'segmentation'
        subfolder1 = 'segmentation';
        subfolder2 = fullfile(subfolder1,'section1');
        
end
rootfolder = fileparts(folder);

if movefolders
    display('Moving files...')
    switch layerJSON.typ
        case 'color'
            if ~exist(folder, 'dir')
                mkdir(folder)    % remake savefolder
            end
        case 'segmentation'
            folder = rootfolder;  % in this case folder is the globalSeg, no need to remake it
    end
end
if ~exist(fullfile(folder,subfolder1), 'dir')
    mkdir(fullfile(folder,subfolder1));  % make subfolder color or segmentation
end
if ~exist(fullfile(folder,subfolder2), 'dir')
    mkdir(fullfile(folder,subfolder2));  % make subfolder section1 in case of typ segmentation (for color subfolder2 already exists)
end
if movefolders
    if numel(dir(fullfile(folder,'x*'))) > 0
        movefile(fullfile(folder,'x*'),fullfile(folder,subfolder2,num2str(sectionJSON.resolutions)))  % move knossos cube files to subfolder2
    end
    if exist(fullfile(folder,'mask'),'dir') || domask
        masklayerJSON = layerJSON;
        savejson('', masklayerJSON, 'FileName', fullfile(folder, 'mask', 'layer.json'),'SingletArray',1);
        savejson('', sectionJSON, 'FileName', fullfile(folder,'mask','section.json'),'SingletArray',1);
        if ~exist(fullfile(folder,'mask',num2str(sectionJSON.resolutions)),'dir')
            mkdir(fullfile(folder,'mask',num2str(sectionJSON.resolutions)))
        end
        if numel(dir(fullfile(folder,'mask','x*'))) > 0
            movefile(fullfile(folder,'mask','x*'),fullfile(folder,'mask',num2str(sectionJSON.resolutions)));
        end
    end
end
if strcmp(layerJSON.typ,'color')
    savejson('', settingsJSON, 'FileName',fullfile(folder,'settings.json'),'SingletArray',0);
end
savejson('', layerJSON, 'FileName', fullfile(folder, subfolder1, 'layer.json'),'SingletArray',1);
savejson('', sectionJSON, 'FileName', fullfile(folder, subfolder2, 'section.json'),'SingletArray',1);
if ispc
    fileattrib(folder,'+w','','s') % make folder writable for wK
else
    fileattrib(folder,'+w +x','g','s') % make folder writable for wK
end
display('Done')
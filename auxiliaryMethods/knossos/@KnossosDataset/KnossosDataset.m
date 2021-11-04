classdef KnossosDataset < handle
    %KNOSSOSDATASET Knossos dataset management wrapper class.
    % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

    properties
        root
        prefix
        dtype = 'uint8'
        ending = 'raw'
        suffix = ''
        cubesize = [128 128 128 1];
    end

    methods
        function obj = KnossosDataset(varargin)
            % Class constructor
            % obj = KnossosDataset() default constructor not pointing to
            %   any knossos dataset.
            %
            % obj = KnossosDataset(p) construct a knossos dataset from a
            %   parameter struct. p must contain the field root containing
            %   path to the knossos hierarchy root folder. Furthermore, p
            %   can contain the fields prefix for the raw filename prefix
            %   (filenames are of the form
            %   prefix_x0001_y0001_z0001_suffix.raw), dtype to specify the
            %   datatype as string (Default: 'uint8') and suffix. Cubesize
            %   must be set manually if it differs from [128 128 128 1].
            %
            % obj = KnossosDataset(root, prefix, dtype, cubesize)
            % INPUT root: Root folder to knossos hierarchy (i.e. the folder
            %           containing the x00... folders).
            %       prefix: (Optional) string
            %           String containing the filename prefix.
            %           Filenames are of the form
            %           prefix_x0001_y0001_z0001_suffix.raw
            %           (Default: Determined from raw files)
            %       dtype: (Optional) Datatype used in knossos hierarchy.
            %           (Default: 'uint8')
            %       cubesize: [1x3] or [1x4] integer specifying the size
            %           of knossos cubes. The fourth number corresponds to
            %           channels.
            %           (Default: [128 128 128 1])

            if isempty(varargin)
                %empty constructor
            elseif length(varargin) == 1 && isstruct(varargin{1})
                %constructor from parameter struct
                p = varargin{1};
                obj.root = Util.addFilesep(p.root);
                if isfield(p, 'prefix')
                    obj.prefix = p.prefix;
                else
                    obj.prefix = obj.getPrefix();
                end
                if isfield(p,'dtype')
                    obj.dtype = p.dtype;
                end
                if isfield(p,'cubesize')
                    obj.cubesize = p.cubesize(:)';
                end
            elseif length(varargin) >= 1 && ischar(varargin{1})
                %constructor with direct input
                obj.root = Util.addFilesep(varargin{1});
                if length(varargin) >= 2 && ~isempty(varargin{2})
                    obj.prefix = varargin{2};
                else
                    obj.prefix = obj.getPrefix();
                end
                if length(varargin) >= 3 && ~isempty(varargin{3})
                    obj.dtype = varargin{3};
                end
                if length(varargin) >= 4 && ~isempty(varargin{4})
                    varargin{4}(end+1:4) = 1;
                    obj.cubesize = varargin{4}(:)';
                end
            else
                error('Unknown input format.'),
            end

            if ~exist(obj.root, 'dir')
                warning('Knossos dataset root does not exist.');
            end
        end
        

        function s = toStruct(obj)
            %Return a struct containing all object properties.
            % OUTPUT s: Struct with fields corresponding to the object
            %           poperties.
            %
            % NOTE see KnossosDataset.fromStruct and
            %      Knossos.Dataset.loadFromStruct

            s = struct();
            for field = fieldnames(obj)'
                s.(field{1}) = obj.(field{1});
            end
        end

        function saveAsStruct(obj, filename, varname)
            %Save the object properties as a struct with name 'kdStruct'
            % INPUT filename: String filename (see MATLAB save).
            %       varname: (Optional) string
            %           Variable name in output file.
            %           (Default: 'kdstruct')
            %
            % NOTE see KnossosDataset.fromStruct and
            %      Knossos.Dataset.loadFromStruct

            if ~exist('varname', 'var') || isempty(varname)
                varname = kdStruct;
            end

            m.(varname) = obj.toStruct(); %#ok<STRNU>
            save(filename, '-struct', 'm', varname);
        end
    end

    methods (Static)

        function obj = fromStruct(s)
            %Load a StoreEM object saved via saveAsStruct
            % INPUT s: Struct containing a field for each object property.

            obj = KnossosDataset();
            for field = fieldnames(s)'
                obj.(field{1}) = s.(field{1});
            end
        end

        function obj = loadFromStruct(filename, varname)
            %Construct a store object from a struct returned by toStruct()
            % INPUT filename: String containing path to saved parameter struct.
            %       varname: (Optional) string
            %           Variable name of the KnossosDataset parameter
            %           struct in the matfile.
            %           (Default: 'kdstruct')

            if ~exist('varname', 'var') || isempty(varname)
                varname = kdStruct;
            end

            m = load(filename);
            if isfield(m, varname)
                obj = KnossosDataset.fromStruct(m.(varname));
            else
                error('%s does not contain a variable called kdStruct');
            end
        end
    end
end

classdef SparseCellArray
    %SPARSECELLARRAY Sparse cell array.
    % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    
    properties
        idx %linear indices of non-empty cells, should be sorted in
            %increasing order
        data %the data of the non-empty cells
        shape %the shape of the cell array
    end
    
    methods
        function obj = SparseCellArray(c)
            %Construct a sparse cell array from the dense input cell array.
            % INPUT c: (Optional) Cell array to initialize the struct.
            %           (Default: Empty sparse cell array).
            
            if exist('c','var') && ~isempty(c)
                obj = obj.init(c);
            end
        end
        
        function obj = init(obj, c)
            %Initialize the sparse cell array from a cell array.
            % INPUT c: Cell array to initialize the struct.
            
            obj.shape = size(c);
            tmp = cellfun(@isempty,c);
            obj.idx = sparse(find(~tmp(:)),1,1:sum(~tmp(:)),numel(c),1);
            obj.data = c(~tmp);
        end
        
        function c = full(obj)
            % Return the sparse cell array to a dense cell array.
            c = cell(obj.shape);
            c(obj.idx > 0) = obj.data;
        end
        
        function isSparse = issparse(~)
            isSparse = true;
        end
        
        function out = cellfun(obj, func, uo)
            %Apply the function handle to each cell of the current array.
            % INPUT func: Function handle with one input.
            %       uo: (Optional) Logical corresponding to 'UniformOutput'
            %           of the cellfun for dense cell arrays.
            %           (Default: true)
            %
            % NOTE Since matlab does not support sparse n-dimensional
            %      arrays the output is saved as a sparse 1-dimensional
            %      if the sparse cell array has more than two dimensions.
            
            if ~exist('uo','var') || isempty(uo)
                uo = true;
            end
            
            r = cellfun(func,obj.data,'UniformOutput',uo);
            if uo
                out = sparse(find(obj.idx > 0),1,r,length(obj.idx),1);
                if islogical(r)
                    out = logical(out);
                end
                if length(obj.shape) == 2
                    out = reshape(out,obj.shape(1),obj.shape(2));
                end
            else
                out = obj;
                out.data = r;
            end
        end
        
        function out = subsref(obj, s)
            %Direct indexing of SparseCellArray object.
            
            switch s(1).type
                case {'()','{}'}
                    subs = s.subs;
                    if all(size(subs) == [1, length(obj.shape)])
                         %convert subscritps to linear indices
                        coords = cell(1,length(obj.shape));
                        for i = 1:length(subs)
                            if strcmp(subs{i},':')
                                subs{i} = 1:obj.shape;
                            end
                        end
                        [coords{:}] = ndgrid(subs{:});
                        subs = sub2ind(obj.shape, coords{:});
                    elseif numel(subs) == 1
                        subs = subs{1};
                    else
                        error('Unsupported indexing.');
                    end
                    
                    %linear indices
                    if max(subs) > prod(obj.shape)
                        error('Index exceeds matrix dimension.');
                    end
                    currIdx = obj.idx(subs);
                    out = cell(size(subs));
                    out(currIdx > 0) = obj.data(currIdx(currIdx > 0));
                    if strcmp(s(1).type, '{}')
                        out = out{:};
                    end
                case '.' %descent on fields
                    out = builtin('subsref', obj, s);
            end
        end
    end
    
    methods (Static)
        function obj = vertcat(c)
            %Vertical concatenation of sparse cell arrays.
            % INPUT c: [Nx1] Cell array of SparseCellArray object.
            % OUTPUT obj: Single SparseCellArray.
            
            if isrow(c)
                c = c';
            end
            sz = cell2mat(cellfun(@(x)x.shape,c,'UniformOutput',false));
            if any(diff(sz(:,2:end),1))
                error('All dimensions but the first one must be equal.');
            end
            newShape = [sum(sz(:,1)), sz(1,2:end)];
            newData = {};
            newIdx = [];
            szCount = 0;
            for i = 1:length(c)
                newData = cat(1,newData,c{i}.data);
                newIdx = cat(1,newIdx, ...
                    Util.SparseCellArray.convertIndRef( ...
                    find(c{i}.idx), c{i}.shape, newShape) + szCount); %#ok<FNDSB>
                szCount = c{i}.shape(1);
            end
            [newIdx,sI] = sort(newIdx);
            obj = Util.SparseCellArray();
            obj.shape = newShape;
            obj.data = newData(sI);
            obj.idx = sparse(newIdx,1,1:length(newIdx),prod(newShape),1);
        end
        
        function [ ind ] = convertIndRef( ind, sizOld, sizNew )
        %CONVERTINDREF Convert linear indices reference cube size.
        % INPUT ind: [Nx1] array of linear indices.
        %       sizOld: [Nx1] array of array size to which in refer.
        %       sizNew: [Nx1] array of array size to which the new output indices
        %           refer.
        % OUTPUT ind: [Nx1] array of linear indices with respect to sizNew.
        % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

        if any(sizOld > sizNew)
            error('The new array must be larger than the old one.');
        end

        x = cell(length(sizOld));
        [x{:}] = ind2sub(sizOld,ind);
        ind = sub2ind(sizNew,x{:});

        end
    end
    
end


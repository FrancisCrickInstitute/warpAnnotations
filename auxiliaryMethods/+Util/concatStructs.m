function out = concatStructs(dim, varargin)
    % out = concatStructs(dim, varargin)
    %   Concatenates the fields of multiple structures.
    %
    % Input arguments
    %   dim
    %     Specifies the dimension along which the fields will
    %     be concatenated. If `dim` is
    %     a) a positive scalar, all fields will be concatenated
    %        along the dimension `dim`
    %     b) a numeric vector with dimension indices, field `i`
    %        will be concatenated along dimension `dim(i)`
    %     c) a structure, the field named `n` will be concatenated
    %        along dimension `dim.(n)`
    %     d) the string 'last', each field will be concatenated
    %        along its last non-singleton dimension.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    inCount = numel(varargin);
    
    % empty input?
    if ~inCount
        out = struct;
        return;
    end;
    
    % init output
    out = varargin{1};
    fieldNames = fieldnames(out);
    
    if isstruct(dim)
        assert(isequal(fieldnames(dim), fieldNames));
        dimVec = cellfun(@(curName) dim.(curName), fieldNames);
    elseif isscalar(dim) && dim > 0
        % expand scalar
        dimVec = repmat(dim, 1, numel(fieldNames));
    elseif ischar(dim) && strcmp(dim, 'last')
        % last non-sinleton dimension
        findLastDim = @(arr) max([1, find(size(arr) > 1, 1, 'last')]);
        dimVec = cellfun(@(n) findLastDim(out.(n)), fieldNames);
        % enable zero length dimension concatenation (empty structs)
        findZeroDim = @(arr) find(size(arr) == 0, 1, 'last');
        lastZero = cellfun(@(n) findZeroDim(out.(n)), fieldNames,'uni',0);
        dimVec(~cellfun(@isempty,lastZero)) = cat(1,lastZero{~cellfun(@isempty,lastZero)});
    else
        assert(isvector(dim));
        assert(numel(fieldNames) == numel(dim));
        dimVec = dim;
    end
    
    for curIdx = 2:inCount
        curStruct = varargin{curIdx};
        out = contactTwoStructs(dimVec, out, curStruct);
    end
end

function out = contactTwoStructs(dimVec, out, b)
    % check the the fields are them same
    fieldNames = fieldnames(out);
    assert(isequal(fieldNames, fieldnames(b)));
    
    % concat each field
    for curIdx = 1:numel(fieldNames)
        curDim = dimVec(curIdx);
        curName = fieldNames{curIdx};
        out.(curName) = cat(curDim, out.(curName), b.(curName));
    end
end

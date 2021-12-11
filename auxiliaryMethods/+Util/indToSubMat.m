function subMat = indToSubMat(size, ind)
    dimCount = numel(size);
    
    % convert indices to subscripts
    subMat = cell(dimCount, 1);
   [subMat{:}] = ind2sub(size, ind);
    
    % build matrix
    subMat = horzcat(subMat{:});
end

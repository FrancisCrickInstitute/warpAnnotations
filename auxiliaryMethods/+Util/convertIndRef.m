function [ idx ] = convertIndRef( idx, bboxOld, bboxNew )
%CONVERTINDREF Convert the reference bounding box of linear indices.
% INPUT idx: [Nx1] int array of linear indices w.r.t to bboxOld.
%       bboxOld: [3x2] int bounding box of current indices.
%       bboxNew: [3x2] int of boundinb box to which indices are transfered.
% OUTPUT idx: [Nx1] int array of linear indices w.r.t. to bboxNew.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%calculate subscripts from indices
sizOld = diff(bboxOld') + 1;
x = cell(length(sizOld),1);
[x{:}] = ind2sub(sizOld,idx);

%translate x to new zero of cube and calculate linear indices
x = arrayfun(@(u,v) u{1} + v,x,bboxOld(:,1) - bboxNew(:,1), ...
    'UniformOutput',false);
sizNew = diff(bboxNew') + 1;
idx = sub2ind(sizNew,x{:});

end


function area = physicalBorderArea2(borders, edges, seg, scale, isPadded)
    % PHYSICALBORDERAREA2
    %   Calculate the physical border area using the algorithm
    %   from Moritz Retina paper.
    % 
    % INPUTS  borders:  Structure array with PixelIdxList field or cell
    %                   array of linear voxel indices. In both cases the
    %                   array must contain N elements.
    %         edges:    N x M matrix (typically, M = 2) of segments. Each
    %                   row contains a list M global segment IDs, which
    %                   define the border.
    %         seg:      Matrix to which the indices in borders refer.
    %         scale:    Voxel size in nm.
    %         isPadded: Set to true, if seg was alreaded padded and the
    %                   borders fixed accordingly. Default: false.
    % 
    % OUTPUT  area: The area of each border in um.
    % 
    % AUTHOR  Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    
    if ~exist('isPadded', 'var')
        isPadded = false;
    else
        assert(islogical(isPadded));
    end
    
    if isstruct(borders)
        % convert into cell array
        borders = {borders.PixelIdxList};
    else
        assert(iscell(borders));
    end
    
    if ~isPadded
        % padding is required. let's do it
        [seg, borders] = doPadding(seg, borders);
    end
    
    % compute shifts along X, Y
    % and Z axis in linear indices
    [M, N, ~] = size(seg);

    xNeigh = [  -1,   1];
    yNeigh = [  -M,   M];
    zNeigh = [-N*M, N*M];

    % compute area for simple contacts
    xA = scale(2) * scale(3);
    yA = scale(1) * scale(3);
    zA = scale(1) * scale(2);

    % temporary values
    a = sqrt(scale(1) ^ 2 + scale(2) ^ 2);
    b = sqrt(scale(1) ^ 2 + scale(3) ^ 2);
    c = sqrt(scale(2) ^ 2 + scale(3) ^ 2);

    % areas for two contact areas
    xyA = a * scale(3);
    xzA = b * scale(2);
    yzA = c * scale(1);

    % area for three contact areas
    s = (a + b + c) / 2;
    xyzA = sqrt(s * (s - a) * (s - b) * (s - c));

    % prepare output
    area = nan(numel(borders), 1);
    edges = double(edges);

    for i = 1:numel(borders)
        %get border pixels
        idx = double(borders{i});

        %determine direction sets
        dX = any(ismember(seg(bsxfun(@plus, idx, xNeigh)), edges(i, :)), 2);
        dY = any(ismember(seg(bsxfun(@plus, idx, yNeigh)), edges(i, :)), 2);
        dZ = any(ismember(seg(bsxfun(@plus, idx, zNeigh)), edges(i, :)), 2);

        %calculate area
        tmp = ...
              xA .* ( dX & ~dY & ~dZ) ...
          +   yA .* (~dX &  dY & ~dZ) ...
          +   zA .* (~dX & ~dY &  dZ) ...
          +  xyA .* ( dX &  dY & ~dZ) ...
          +  xzA .* ( dX & ~dY &  dZ) ...
          +  yzA .* (~dX &  dY &  dZ) ...
          + xyzA .* ( dX &  dY &  dZ);
        area(i) = sum(tmp);
    end
    
    % convert output to um^2
    area = area / 1E6;
end

function [seg, borders] = doPadding(seg, borders)
    % add padding to prevent out-of-bounds
    % error later on when applying shifts
    segSizeOld = size(seg);
    seg = padarray(seg, [1, 1, 1], 0);
    
    % correct indices for padding
    fixFunc = @(ids) fixVoxelIds(segSizeOld, size(seg), ids);
    borders = cellfun(fixFunc, borders, 'UniformOutput', false);
end

function ids = fixVoxelIds(oldSize, newSize, ids)
    [xVec, yVec, zVec] = ind2sub(oldSize, ids(:));
    ids = sub2ind(newSize, xVec + 1, yVec + 1, zVec + 1);
end

function bboxMat = convertWebknossosToMatlabBbox(bboxWeb)
    % Convert bounding box used in webKnossos to the one used in e.g. readKnossoRoi, pipeline repo etc.
    if any(size(bboxWeb)==6)
        bboxMat = reshape(bboxWeb, 3, 2);
        bboxMat(:,1) = bboxMat(:,1) + 1;
        bboxMat(:,2) = bboxMat(:,1) + bboxMat(:,2) - 1;
    elseif all(size(bboxWeb) == [3,2])
        display('Bounding box already in Matlab format. Nothing is done')
        bboxMat = bboxWeb;
    else
        error('Unknown bbox format')
    end

end


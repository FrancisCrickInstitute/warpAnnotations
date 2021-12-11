function [ bboxWeb ] = convertMatlabToWKBbox( bboxMat )
% Convert bounding box used in Matlab to the one used in Webknossos
    bboxWeb=zeros(1,6);
    bboxWeb(1:3)=bboxMat(:,1);    
    bboxWeb(4:6) = diff(bboxMat,1,2)+1;
    fprintf('%u,%u,%u,%u,%u,%u',bboxWeb);
end


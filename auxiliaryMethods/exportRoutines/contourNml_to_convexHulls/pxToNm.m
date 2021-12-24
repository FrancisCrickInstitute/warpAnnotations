% function to convert array of pixel coord into nm, extracting scale from
% the skeleton
% todo: add optional argument to specify output in um or nm
function cxUm = pxToNm(cxPx,skel)
cxUm(:,1) = cxPx(:,1)*skel.scale(1);
cxUm(:,2) = cxPx(:,2)*skel.scale(2);
cxUm(:,3) = cxPx(:,3)*skel.scale(3);

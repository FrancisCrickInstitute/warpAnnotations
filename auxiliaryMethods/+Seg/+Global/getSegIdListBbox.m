function [ encompassingBbox ] = getSegIdListBbox( param,segIdList,bboxMap )
%GETSEGIDLISTBBOX This function outputs a bounding box which encompasses
%all the segments in the segIdList.
%Author: Ali Karimi<ali.karimi@brain.mpg.de>
if ~exist('bboxMap','var') || isempty(bboxMap)
bboxMap=Seg.Global.getSegToBoxMap(param);
end
% Get all the segmentId bboxes
segIdList(segIdList<=0)=[];
allSegBboxes=bboxMap(:,:,segIdList);
minBox=min(allSegBboxes,[],3);
maxBox=max(allSegBboxes,[],3);

%Create the largest bbox containing all the segments
encompassingBbox=[minBox(:,1),maxBox(:,2)];

end


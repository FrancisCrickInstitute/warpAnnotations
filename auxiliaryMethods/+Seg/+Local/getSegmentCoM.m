function com = getSegmentCoM(segments, idList, cubeSize)
%GETSEGMENTCOM Get the center of mass for local segments.
% INPUT segments: The segments struct from p.local(i).segmentFile or the
%           segmentation array from p.local(i).segFile.
%       idList: (Optional) List of segment ids for which the size is
%           calculated. Repeated IDs are allowed.
%           (e.g. [segments(1:10).Ids])
%           (Default: All indices in segments).
%       cubeSize: (Optional) Integer vector specifying the size of a local
%       	segmentation cube. Only required if segments is from
%       	p.local(i).segmentFile.
%       	(Default: [512, 512, 256])
% OUTPUT com: [Nx3] array of single. The i-th row contains the center of mass
%             for the i-th id in idList.
%
% NOTE If the segments struct is used then the com is calculated for the
%      bounding box small.
% NOTE When using the seg array from p.local(i).segFile then it should be
%      used for the large bounding box because otherwise segments could be
%      split when cropping the border.
% NOTE Use uint16(bsxfun(@plus,localCoMs,bboxSmall(:,1)' - 1)) to convert
%      the local indices to global indices.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('cubeSize','var') || isempty(cubeSize)
    cubeSize = [512, 512, 256];
elseif iscolumn(cubeSize)
    cubeSize = cubeSize';
end

%handles repeated IDs
if ~exist('idList','var') || isempty(idList)
    if isstruct(segments)
        idList = [segments(:).Id];
    else
        idList = setdiff(unique(segments(:)),0);
    end
end
[uIDList,~,ic] = unique(idList);

%calculate com
ucom = zeros(length(uIDList),3,'single');
if isstruct(segments)
    segIDs = [segments(:).Id];
    for uid = 1:length(uIDList)
        [x,y,z] = ind2sub(cubeSize, [segments(segIDs == uIDList(uid)).PixelIdxList] );
        ucom(uid,:) = sum([x,y,z],1)./length(x);
    end
else
    stats = regionprops(segments, segments, 'Centroid', 'MinIntensity');
    stats(cellfun(@isempty,{stats(:).MinIntensity})) = [];
    ucom = [stats(ismember([stats(:).MinIntensity], double(uIDList))).Centroid];
    ucom = reshape(ucom,3,[])';
    ucom = ucom(:,[2 1 3]); %regionprops seems to interchange x and y
end

com = ucom(ic,:);

end

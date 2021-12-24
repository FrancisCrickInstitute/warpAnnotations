function [ comMapped ] = applyMappingToCoM( segSize, com, mapping )
%APPLYMAPPINGTOCOM Calculate the segment center of mass after mapping by
%combining the coms of the local weighted by their size.
% INPUT segSize: see getGlobalSegmentSize
%       com: see getGlobalCoMList
%       mapping: see getGlobalMapping
% OUTPUT comMapped: The coms for the mapped segments.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

fprintf('[%s] Combining CoMs via mapping.\n',datestr(now));

%sort by group of ids that are mapped to same segment
[sMapping, sIdx] = sort(mapping);
unsortIdx = zeros(length(mapping),1);
unsortIdx(sIdx) = 1:length(mapping);
edges = [1:length(sMapping) - 1; 2:length(sMapping)]';
groupIdx = diff(sMapping) == 0;
edges(~groupIdx,:) = [];
pre = Graph.findConnectedComponents(edges);

%sort other indices
sSegSize = single(segSize(sIdx));
sCom = single(com(sIdx,:));

%create com for unmodified ids
comMapped = zeros(length(mapping),3,'like',com);
idxSingle = true(length(mapping),1);
idxSingle(cell2mat(pre)) = false;
comMapped(idxSingle,:) = sCom(idxSingle,:);

%create coms for modified ids
for i = 1:length(pre)
    if sum(sSegSize(pre{i})) > 0
        currCom = sum(bsxfun(@times,sCom(pre{i},:),sSegSize(pre{i})),1)./sum(sSegSize(pre{i}));
        comMapped(pre{i}(1),:) = currCom;
        pre{i} = sIdx(pre{i}(2:end));
    end
end

%restore id order
comMapped = comMapped(unsortIdx,:);
comMapped(cell2mat(pre),:) = [];

if size(comMapped,1) ~= max(mapping)
    warning('Size inconsistency for resulting comMapped. It seems some error occured.');
end
end


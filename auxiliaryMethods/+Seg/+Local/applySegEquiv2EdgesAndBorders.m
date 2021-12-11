function [ edges, borders, idx, borderIn2Out ] = ...
    applySegEquiv2EdgesAndBorders( eClasses, edges, borders, cubeSize )
%APPLYSEGEQUIV2EDGES Apply a segment equivalence relation to the edge list.
% INPUT eClasses: [Nx1] cell array. Each entry contains an [Mx1] numerical
%           array specifying the segment IDs which should be merged.
%       edges: [Nx2] array of integer containing the edges in the adjacency
%           graph contained in seg.
%       borders: borders: Struct containing the borders between edges.
%       cubeSize: (Optional) [1x3] array of integer given the size of the
%           local segmentation cube to which the linear indices in borders
%           refer. This is used to recalculate the centroids of borders.
%           (Default: [512, 512, 256]).
% OUTPUT edges: [Nx2] array of integer containing the edge list with edges
%           between equivalent segments removed.
%        borders: The borders struct for the output edges.
%        idx: [Nx1] logical array of length size(edges,1) containing the
%           original edges that are kept. I.e. edges(idx,:) for the input
%           edges should give the output edges.
%        borderIn2Out: [Nx1] cell
%           Cell array of same length as borders output containing the
%           linear indices of the input borders that are combined into the
%           corresponding output border.
%
% see also Seg.Local.applySegEquiv
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('cubeSize','var') || isempty(cubeSize)
    cubeSize = [512, 512, 256];
end

borderPixelOrderIsRow = isrow(borders(1).PixelIdxList);

%get new edges
modifiedEdgesIdx = false(size(edges,1),1);
for i = 1:length(eClasses)

    %replace all ids of equivalence class by first entry in eClass
    toReplace = ismember(edges, eClasses{i});
    edges(toReplace) = eClasses{i}(1);

    %outgoing edges from current agglomeration
    modifiedEdgesIdx = modifiedEdgesIdx | ...
        xor(toReplace(:,1),toReplace(:,2));
end

%modified edges between same ids
modifiedEdgesIdx = find(modifiedEdgesIdx);
modifiedEdges = sort(edges(modifiedEdgesIdx,:),2);
[~,~,ic] = unique(modifiedEdges, 'rows', 'stable');
[ics, sIdx] = sort(ic);
icsIdx = [find([true; diff(ics)]); length(ics) + 1];

%check if borders are now connected
toDelBorders = zeros(0, 1, 'like', edges);
borderIn2Out = num2cell(1:length(borders))';
for i = 1:length(icsIdx) - 1
    borderIdx = modifiedEdgesIdx(sIdx(icsIdx(i):icsIdx(i+1)-1));
    if length(borderIdx) > 1
        
        %calculate connected components of borders
        cc = zeros(1, length(borderIdx));
        for k = 1:length(borderIdx)
            groupMember = false(1,length(borderIdx));
            groupMember(k) = true;
            for l = (k + 1):length(borderIdx)
                %determine if they share voxels
                if borderPixelOrderIsRow
                    groupMember(l) = ~all(diff( ...
                        sort([borders(borderIdx(k)).PixelIdxList, ...
                              borders(borderIdx(l)).PixelIdxList])));
                else
                    groupMember(l) = ~all(diff( ...
                        sort([borders(borderIdx(k)).PixelIdxList; ...
                              borders(borderIdx(l)).PixelIdxList])));
                end
            end
            groupIds = cc(groupMember);
            if ~any(groupIds)
                cc(groupMember) = max(cc) + 1;
            else
                cc(ismember(cc,groupIds(groupIds > 0)) | groupMember) = ...
                    min(groupIds(groupIds > 0));
            end
        end
        
        %merge borders that are connected now und update area and centroid
        for k = unique(cc)
            idx = find(cc == k);
            if length(idx) == 1
                continue
            end
            %save everything to first border idx
            for l = 2:length(idx)
                if borderPixelOrderIsRow
                    borders(borderIdx(idx(1))).PixelIdxList = cat(2, ...
                        borders(borderIdx(idx(1))).PixelIdxList, ...
                        borders(borderIdx(idx(l))).PixelIdxList);
                else
                    borders(borderIdx(idx(1))).PixelIdxList = cat(1, ...
                        borders(borderIdx(idx(1))).PixelIdxList, ...
                        borders(borderIdx(idx(l))).PixelIdxList);
                end
            end
            borderIn2Out{borderIdx(idx(1))} = borderIdx(idx);

            %delete repeating indices
            borders(borderIdx(idx(1))).PixelIdxList = ...
                unique(borders(borderIdx(idx(1))).PixelIdxList);

            %delete other borders
            toDelBorders = cat(1,toDelBorders,borderIdx(idx(2:end)));

            %calculate new area and centroid
            borders(borderIdx(idx(1))).Area = ...
                length(borders(borderIdx(idx(1))).PixelIdxList);
            borders(borderIdx(idx(1))).Centroid = ...
                Util.centroidFromLinearInd( ...
                    borders(borderIdx(idx(1))).PixelIdxList, cubeSize);
        end
    end
end

%delete edges and borders between same segment
toDel = diff(double(edges),1,2) == 0; %double necessary if edge not properly sorted
toDel(toDelBorders) = true;
edges = edges(~toDel,:);
borders(toDel) = [];
idx = ~toDel;
borderIn2Out(toDel) = [];

end




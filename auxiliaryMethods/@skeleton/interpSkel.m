function skelI = interpSkel( skel, treeInds, intf )
%NUMNODES Performs linear interpolation between the nodes of a tree.
% INPUT treeIdx: (Optional) Tree index for which the interpolation should
%           be performed
%       intf: (Optional) Interpolation (Upsample) Factor
%
% Author: Florian Drawitsch <florian.drawitsch@brain.mpg.de>

if ~exist('treeInds','var') || isempty(treeInds)
    treeInds = 1:numel(skel.names);
end

if ~exist('intf','var')
    intf = 2;
end

lv = linspace(0,1,intf*2)';
skelI = skel;
for treeIdx = treeInds
    skelI.edges{treeIdx} = [];
    for edgeIdx = 1:size(skel.edges{treeIdx},1)
        thisEdge = skel.edges{treeIdx}(edgeIdx,:);
        n1 = skel.nodes{treeIdx}(thisEdge(1),1:3);
        n2 = skel.nodes{treeIdx}(thisEdge(2),1:3);
        tmp = unique(n1 + floor((n2 - n1).*lv),'rows');
        nodesAll = [tmp, repmat(skel.nodes{treeIdx}(thisEdge(1),4),size(tmp,1),1)];
        nodesNew = nodesAll(2:end-1,:);
        connectTo = thisEdge(1);
        for nn = 1:size(nodesNew,1)
            [skelI, addedEdge] = addNode(skelI, treeIdx, nodesNew(nn,1:3), connectTo, nodesNew(nn,4));
            connectTo = addedEdge;
        end
        skelI.edges{treeIdx} = [skelI.edges{treeIdx}; [connectTo thisEdge(2)]];
    end
end

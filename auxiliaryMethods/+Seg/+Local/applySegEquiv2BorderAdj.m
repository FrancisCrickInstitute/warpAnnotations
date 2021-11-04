function [ edges, borderIn2Out ] = applySegEquiv2BorderAdj( eClasses, edges, borders, borderAdj )
%APPLYSEGEQUIV2BORDERADJ Calculate agglomerated borders from a segment
%equivalence class using a borderAdjacency graph.
% INPUT eClasses: [Nx1] cell
%           Each cell contains the ids of one segment equivalence class.
%       edges: [Nx2] int
%           see SynEM.Svg.findEdgesAndBorders
%       borders: [Nx1] struct
%           see SynEM.Svg.findEdgesAndBorders
%       borderAdj: [Nx2] int
%           see SynEM.Svg.findEdgesAndBorders
% OUTPUT edges: [Nx2]
%           The agglomerated edges.
%        borderIn2Out: [Nx1] cell
%           Cell array of same length as size(edges,1) output containing
%           the linear indices of the input borders that are combined into
%           the corresponding output border.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%get borderAdj lookup
bAdjLookup = Seg.Global.getEdgeLookupTable(borderAdj);

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
toDelEdges = false(size(edges,1),1);
borderIn2Out = num2cell(1:length(borders))';
for i = 1:length(icsIdx) - 1
    borderIdx = modifiedEdgesIdx(sIdx(icsIdx(i):icsIdx(i+1)-1));
    
    if length(borderIdx) == 1 %nothing to do
        continue;
    end
    
    %get connected components of borders
    subgraph = borderAdj(unique(cell2mat(bAdjLookup(borderIdx))),:);
    subgraph = subgraph(all(ismember(subgraph, borderIdx),2),:);
%     comps = Graph.findConnectedComponents(subgraph);
%     comps = cat(1, comps, num2cell(setdiff(borderIdx, cell2mat(comps))));
    comps = connectedComponents(borderIdx, subgraph);

    for j = 1:length(comps)
        %combine borders that are now connected
        borderIn2Out{comps{j}(1)} = comps{j};
        
        %delete edges that are now grouped
        toDelEdges(comps{j}(2:end)) = true;
    end
end

toDelEdges = toDelEdges | diff(double(edges), 1, 2) == 0;
edges(toDelEdges,:) = [];
borderIn2Out(toDelEdges) = [];

end

function comps = connectedComponents(nodes, edges)
if isempty(edges)
    comps = num2cell(nodes);
else
    s = sparse(nodes,1,1:length(nodes));
    edges = reshape(full(s(edges)), size(edges));
    g = graph(edges(:,1), edges(:,2));
    comps = g.conncomp();
    comps(end+1:length(nodes)) = (1:(length(nodes) - length(comps))) + ...
                                max(comps);
    comps = accumarray(comps', nodes, [], @(x){sort(x)});
end
end


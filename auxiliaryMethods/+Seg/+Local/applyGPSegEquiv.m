function [ eClasses, seg, edges, borders ] = applyGPSegEquiv( pCube, gpT )
%APPLYGPSEGEQUIV Merge segments based on the GP probabilities.
% INPUT pCube: Parameter struct for a local segmentation cube, e.g.
%       	p.local(1)
%       gpT: Double specifying the threshold on the GP probabilities above
%           which segments get merged.
% OUTPUT eClasses: The equivalence classes used for agglomeration.
%        seg: The updated segmentation of the local cube.
%        edges: [Nx2] the udpated edge list of the local cube.
%        borders: The updated borders of the local cube.
%
% see also Seg.Local.applySegEquiv
%
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

%calculate equivalence classes
m = load(pCube.edgeFile);
edges = m.edges;
m = load(pCube.probFile);
prob = m.prob;
eClasses = Graph.findConnectedComponents(edges(prob > gpT,:));

%apply equivalence relation
seg = Seg.Local.getSegSmall(pCube,true);
m = load(pCube.borderFile);
borders = m.borders;
m = load(pCube.segmentFile);
segments = m.segments;
[seg, edges, borders] = Seg.Local.applySegEquiv(eClasses, seg, edges, borders, segments);

end


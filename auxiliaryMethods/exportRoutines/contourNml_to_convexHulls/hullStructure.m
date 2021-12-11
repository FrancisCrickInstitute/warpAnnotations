% get convex hull from contour skeleton in a structure format that can be saved into amira-readable ply format
% useful for visualising glomeruli
function S = hullStructure(skel,treeID)
contourCx = pxToNm(skel.nodes{treeID}(:,1:3),skel);   % coord in nm
DT_contourCx = delaunayTriangulation(contourCx(:,1), contourCx(:,2),contourCx(:,3));
hull_contourCx = convexHull(DT_contourCx);

S = struct();
S.faces = hull_contourCx;
S.vertices = cat(2, DT_contourCx.Points(:,1), DT_contourCx.Points(:,2), DT_contourCx.Points(:,3));

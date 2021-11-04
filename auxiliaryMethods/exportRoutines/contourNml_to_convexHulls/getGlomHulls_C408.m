%% INITIALISATION
% path to source skeletons, output directory and output file name
sourceSkelPath = '/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/hulls_to_amira/C408_O174_contour.nml';
outputPath = '/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/hulls_to_amira';
outputFileName = 'C408_O174_contour.ply';
voxelSize = [64 64 128];

%% load skeletons
% glomerulus contours
G = skeleton([sourceSkelPath]);
% somata = skeleton('C408_someMCseeds');

%% color
colorPalette16 = [230 25 75; 60 180 75; 255 225 25; 0 130 200; 245 130 48; 145 30 180; 70 240 240; 240 50 230; 210 245 60; 250 190 190; 0 128 128; 230 190 255; 170 110 40; 255 250 200; 128 0 0; 170 255 195];
colorPalette16N = colorPalette16/255;
% palette taken from https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
%% get convex hulls of glomerulus contours (in a format that is useful for exporting into amira later on)
g1_hull = hullStructure(G,1);
% g2_hull = hullStructure(G,2);
% g3_hull = hullStructure(G,3);
% g4_hull = hullStructure(G,4);
% g5_hull = hullStructure(G,5);
% g6_hull = hullStructure(G,6);
% g7_hull = hullStructure(G,7);
% g8_hull = hullStructure(G,8);
% g9_hull = hullStructure(G,9);
% g10_hull = hullStructure(G,10);
% g11_hull = hullStructure(G,11);
% g12_hull = hullStructure(G,12);
% g13_hull = hullStructure(G,13);
% g14_hull = hullStructure(G,14);


%% save structured hulls as ply files (amira-readable)
Visualization.writePLY(g1_hull, colorPalette16N(1,:), [outputPath filesep outputFileName]);

% Visualization.writePLY(g1_hull, colorPalette16N(1,:), 'g1_hull.ply');
% Visualization.writePLY(g2_hull, colorPalette16N(2,:), 'g2_hull.ply');
% Visualization.writePLY(g3_hull, colorPalette16N(3,:), 'g3_hull.ply');
% Visualization.writePLY(g4_hull, colorPalette16N(4,:), 'g4_hull.ply');
% Visualization.writePLY(g5_hull, colorPalette16N(5,:), 'g5_hull.ply');
% Visualization.writePLY(g6_hull, colorPalette16N(6,:), 'g6_hull.ply');
% Visualization.writePLY(g7_hull, colorPalette16N(7,:), 'g7_hull.ply');
% Visualization.writePLY(g8_hull, colorPalette16N(8,:), 'g8_hull.ply');
% Visualization.writePLY(g9_hull, colorPalette16N(9,:), 'g9_hull.ply');
% Visualization.writePLY(g10_hull, colorPalette16N(10,:), 'g10_hull.ply');
% Visualization.writePLY(g11_hull, colorPalette16N(11,:), 'g11_hull.ply');
% Visualization.writePLY(g12_hull, colorPalette16N(12,:), 'g12_hull.ply');
% Visualization.writePLY(g13_hull, colorPalette16N(13,:), 'g13_hull.ply');
% Visualization.writePLY(g14_hull, colorPalette16N(14,:), 'g14_hull.ply');

%% save other things
% save('colorPalette16N')

%% get soma coords and convert to amira
% somaCoords = getCoord(somata);
% convertCoordToSurface(somaCoords, 'someMCsomata.am', voxelSize, 7000, 50, [0.5020 0 0]);
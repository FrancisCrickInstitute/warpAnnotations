%% Setup
skeletonFile = '/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/skels_to_amira/MC_to_O174_1.nml';
outputFilename = '/data/CB/poiata/MC_to_glom/CLEM_GCaMP_180122/C408/13-EMtoRaw/3-EMraw_mag8-8-4/skels_to_amira/MC_to_O174_1.hoc';
voxelSize = [64 64 128]; % dataset voxel size - original, in mag1 (regardless of what has been imported into amira) 

%% load skeleton
skeleton_obj = {skeleton(skeletonFile)};

%% convert skeleton to amira
convertKnossosNmlToHocAll(skeleton_obj, outputFilename, false, false, false, false, voxelSize);

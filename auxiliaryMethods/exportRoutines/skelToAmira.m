%% Setup
skeletonFile = '/camp/home/berninm/data/C408_skeletons/initial/C408-09_region1.nml';
outputFilename = '/camp/home/berninm/data/C408_skeletons/initial/C408-09_region1.hoc';
voxelSize = [512 512 512]; % dataset voxel size in Amira 

%% load skeleton
skeleton_obj = {skeleton(skeletonFile)};

%% convert skeleton to amira
convertKnossosNmlToHocAll(skeleton_obj, outputFilename, false, false, false, false, voxelSize);

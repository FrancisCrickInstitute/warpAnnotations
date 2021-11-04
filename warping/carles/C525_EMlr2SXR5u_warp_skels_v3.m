% template script to warp coordinates using bigwarp in matlab
% 
% see original in 
% /Users/boschc/Documents/LondonLab/Scripts/repos/matlab-pipeline/warping
% 
% 
%% FUNCTIONALISED SCRIPT
%% 0- init 
%% 0.1- initialise toolbox repos
clearvars;
repoPath = '/Users/boschc/Documents/LondonLab/Scripts/repos/matlab-pipeline';
run(fullfile(repoPath,'auxiliaryMethods','install_auxiliaryMethods.m'));
run(fullfile(repoPath,'startup.m')); % function in the repo that updates the matlab path

% add imageJROI repo path
readRoiPath = '/Users/boschc/Documents/LondonLab/Scripts/repos/fx2EM/readImageJROI';
addpath(genpath(readRoiPath));

%% 0.2- clear vars while debugging
clc
clearvars;

%% 0.3- initialise paths
dirs.ld = '/Users/boschc/Documents/LondonLab/poiata/MC to GlomID/CLEM_GCaMP_181203/C525/30-fx2EM_analysis/3-scripts/training_warp/0-landmarks';
dirs.sk = '/Users/boschc/Documents/LondonLab/poiata/MC to GlomID/CLEM_GCaMP_181203/C525/30-fx2EM_analysis/3-scripts/training_warp/1-skels';
dirs.output = '/Users/boschc/Documents/LondonLab/poiata/MC to GlomID/CLEM_GCaMP_181203/C525/30-fx2EM_analysis/3-scripts/training_warp/2-output/v3';

paths.ld = [dirs.ld filesep 'C525_SXR5u_bboxC525aMag1_to_EMmesh7Mag4_INVERSE.csv'];
paths.skEM = [dirs.sk filesep 'C525a-LR_translationAffine_templateSkel.nml'];
paths.skSXR = [dirs.sk filesep 'C525_DIAMOND_5u_templateSkel.nml'];

%% 0.4- import skels
sk_EM = skeleton(paths.skEM);
sk_SXRtemplate = skeleton(paths.skSXR);

%% 0.5- import warp parameter buckets from datastore ----- USER INPUT -----
% note: should first pixel be index 0 (as in wk) or 1 (as in matlab)?
ds.SXRbbox.bbox = [3630 1 4700 3000 2420 3400]; % ref: https://github.com/cboschp/sampleProcessingLogs/blob/master/200423_C525_SXR5u_wkw2tiff.md
ds.SXRbbox.mag = 1;
ds.SXRbbox.transforms = [0 0 1];        % [hFlip vFlip zReverse], from warp log (to be generated)

ds.EMbbox.bbox = [1 1 1 2309 2309 1242]; % ref: 'https://github.com/cboschp/fx2EM/blob/master/wkw_to_raw/cubesToRaw_C525aLR_mag4.m' and imgSettings file
ds.EMbbox.mag = 4;
ds.EMbbox.transforms = [0 0 0];         % [hFlip vFlip zReverse], from warp log (to be generated)

% define warp direction and steps:
% originWKdataset = C525a-LR_translationAffine;
% targetWKdataset = C525_DIAMOND_5u;
% steps = {offset=0, scale, chirality=0, warp, chirality=1, scale=0,
% offset=1};
% trueSteps = {scale, warp, chirality, offset};

%% 0.6- extract parameters required for the warp ----- NO FURTHER USER INPUT -----
% bboxes and sizes
ds.SXRbbox.offset_px = ds.SXRbbox.bbox(1:3);   % extracted from bbox used when importing the original dataset.
ds.SXRbbox.size = ds.SXRbbox.bbox(4:6);     % extracted from bbox used when importing the original dataset.

ds.EMbbox.offset_px = ds.EMbbox.bbox(1:3);          % extracted from bbox used when importing the original dataset.
ds.EMbbox.size = ds.EMbbox.bbox(4:6);      % TODO: input bbox, and extract offset and size from there!

% scales
scale.EM = sk_EM.scale;
scale.EMbbox = sk_EM.scale .* ds.EMbbox.mag;
scale.SXR = sk_SXRtemplate.scale;
scale.SXRbbox = scale.SXR .* ds.SXRbbox.mag;

%% 1- transform source skeleton
% offset - none in this case
% scale
sk_EMmag4 = scaleNodes(sk_EM, ds.EMbbox.mag);
% chirality - none in this case
%% 2- transform skeleton
sk_warpedRaw = transformNodesNew(sk_EMmag4, paths.ld, scale.SXRbbox, 'test');

%% 3- transform warped skeleton
% chirality
sk_warpedChiral = changeChirality(sk_warpedRaw,  ds.SXRbbox.transforms, ds.SXRbbox.size);
% scale - none in this case

%% offset
sk_wOffset = sk_warpedChiral.translateNodes(ds.SXRbbox.offset_px);

%% 6- save warped skeleton
sk_wOffset.write([dirs.output filesep 'warpedTest.nml']);

import TransformPoints2.*

%% 0.3- initialise paths
dirs.ld = '/camp/home/berninm/repos/matlab-pipeline/warping/carles/0-landmarks';
dirs.sk = '/camp/home/berninm/repos/matlab-pipeline/warping/carles/1-skels';
dirs.output = '/camp/home/berninm/repos/matlab-pipeline/warping/carles/output';

paths.ld = [dirs.ld filesep 'C525_SXR5u_bboxC525bMag1_to_EMmesh7Mag4_INVERSE.csv'];
paths.skEM = [dirs.sk filesep 'C525b-12_mesh7_sourceSkel.nml']; % --> Extract the dataset it comes from
paths.skSXR = [dirs.sk filesep 'C525_DIAMOND_5u_templateSkel.nml'];
outputFilename = [dirs.output filesep 'old_method.nml'];

%% 0.5- import warp parameter buckets from datastore ----- USER INPUT -----
% note: should first pixel be index 0 (as in wk) or 1 (as in matlab)?
ds.SXRbbox.bbox = [1800 290 1400 3000 2110 3000]; % ref: https://github.com/cboschp/sampleProcessingLogs/blob/master/200423_C525_SXR5u_wkw2tiff.md
ds.SXRbbox.mag = 1;
ds.SXRbbox.transforms = [0 0 1];        % [hFlip vFlip zReverse], from warp log (to be generated)

ds.EMbbox.bbox = [1 1 1 3687 3929 2474]; % ref: 'https://github.com/cboschp/sampleProcessingLogs/blob/master/200423_C525_SXR5u_wkw2tiff.md' and imgSettings file
ds.EMbbox.mag = 4;
ds.EMbbox.transforms = [0 0 0];         % [hFlip vFlip zReverse], from warp log (to be generated)

%% 0.4- import skels
sk_EM = skeleton(paths.skEM);
sk_SXRtemplate = skeleton(paths.skSXR);

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
sk_wOffset.write(outputFilename);

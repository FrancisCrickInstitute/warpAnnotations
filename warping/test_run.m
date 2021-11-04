inputFile = '/camp/project/proj-emschaefer/working/otherUsers/berninm/matlab-pipeline/warping/carles/1-skels/C525b-12_mesh7_sourceSkel.nml';
outputFolder = '/camp/home/berninm/';

skEM = skeleton(inputFile);
targets = skEM.warp_targets();
display(targets);
skSXR = skEM.warp(targets{1});
skSXR.write(fullfile(outputFolder, 'sxr_skel.nml'));
reverse_targets = skSXR.warp_targets();
display(reverse_targets);
skEM_again = skSXR.warp(reverse_targets{1});
skEM_again.write(fullfile(outputFolder, 'back_to_em.nml'));


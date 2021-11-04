skel = skeleton('/camp/home/berninm/repos/matlab-pipeline/warping/carles/1-skels/C525b-12_mesh7_sourceSkel.nml');
skel_new = skel.warp('C525_DIAMOND_5u');
skel_new.write('/camp/home/berninm/repos/matlab-pipeline/warping/carles/output/new_method.nml');


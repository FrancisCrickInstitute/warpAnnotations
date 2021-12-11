% Load parameter file from pipeline run (see gitlab pipeline repo)
load /gaba/u/mberning/results/pipeline/20161105_sK15_Str_js_v3/allParameter.mat;
p.kdb.settings.scale = [12 12 30];

% Choose nml file of which trees should be visualized
nmlFile = '/gaba/scratch/mberning/jakobNml/all.nml';
outDir = '/gaba/scratch/mberning/jakobNml/';
Visualization.exportNmlToAmira(p, nmlFile, outDir, 'reduce', 0.5);


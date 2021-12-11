% This script parses SGE-specific options and translates them in to the
% Slurm equivalent.
%
% Written by
%   Alessandro Motta <alessandro.motta@brain.mpg.de>
clear;

%%
cluster = { ...
    '-pe openmp 1', ...
    '-l h_vmem=12G', ...
    '-l h_rt=12:34:56', ...
    '-p -123'};
cluster = strjoin(cluster, {' '});

%% Number of cores
peRegex = '-pe (?<pe>\w+) (?<cores>\d+)';
vmemRegex = 'h_vmem=(?<num>\d+)(?<unit>\w)';
prioRegex = '-p (?<prio>(-|+)?\d+)';
rtRegex = 'h_rt=(?<rt>(\d{1,2}\:){0,2}\d+)';

peOut = regexp(cluster, peRegex, 'names', 'once');
vmemOut = regexp(cluster, vmemRegex, 'names', 'once');
prioOut = regexp(cluster, prioRegex, 'names', 'once');
rtOut = regexp(cluster, rtRegex, 'names', 'once');

numCores = str2double(peOut.cores);

% Why would you use anything different?
assert(vmemOut.unit == 'G');
memoryGb = str2double(vmemOut.num);

% TODO(amotta): Convert to new scale, if needed.
priority = str2double(prioOut.prio);

% Split into hours, minutes, and seconds
runTimeSec = cellfun(@str2double, strsplit(rtOut.rt, ':'));
runTimeSec = [zeros(1, 3 - numel(runTimeSec)), runTimeSec];
runTimeSec = sum(runTimeSec .* (60 .^ [2, 1, 0]));

runTimeHms = cell(1, 3);
[runTimeHms{:}] = hms(seconds(runTimeSec));
runTimeHms = sprintf('%d:%02d:%02d', runTimeHms{:});

%% Build key-value pairs for Slurm module
kvPairs = { ...
    'cores', numCores; ...
    'memory', memoryGb; ...
    'time', runTimeHms; ...
    'priority', priority};
kvPairs = reshape(kvPairs', 1, []);

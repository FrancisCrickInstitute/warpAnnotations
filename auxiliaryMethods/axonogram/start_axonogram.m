%%% skeleton2axonogram
%%% NOV 2015
%%% Helene Schmidt: helene.schmidt@brain.mpg.de


%% load skeletons
addpath('Y:\Analysis\st218 2Amira\auxiliaryMethods-master');
nml_path = 'C:\Users\schmidth\Downloads\MT1 (3).nml';

skel = parseNml(nml_path);
skel = KNOSSOS_attachCommentsToNodes(skel);
skel{1,1}.allComments_assigned(cellfun('isempty', skel{1,1}.allComments_assigned)) = {''};

% get scale
scale = [str2num(skel{1,1}.parameters.scale.x) str2num(skel{1,1}.parameters.scale.y) str2num(skel{1,1}.parameters.scale.z)];

allTreeNames = {};
for tree = 1:size(skel,2)
    allTreeNames{1,tree} = skel{1,tree}.name;
end
allTreeNames(cellfun('isempty', allTreeNames)) = {''};

%% Example tree axonogram
Treename = 'Tree036';
treeID = find(~cellfun('isempty', strfind(allTreeNames, Treename)))
disp(allTreeNames(1,treeID)')

comments = skel{1,1}.allComments_assigned(treeID,:);
tree = skel{1,treeID};

% adjust your starting point here:
startpoint = find(~cellfun('isempty', strfind(comments, 'soma')) & not(~cellfun('isempty', strfind(comments, 'sy')))) ;

TREE = axonogram(tree, comments, startpoint, scale);

%% Example plotting synapses into axonogram

% find all comments you need
idx_sy_all = find(~cellfun('isempty', strfind(comments, 'sy')) & not(~cellfun('isempty', strfind(comments, 'sy?')) | ...
    ~cellfun('isempty', strfind(comments, 'sy ?'))| ...
    ~cellfun('isempty', strfind(comments, 'prob'))));

if ~isempty(idx_sy_all)
    XY = findPointsInAxonogram(idx_sy_all, TREE, tree, scale);
    gcf, plot(XY(:,1),XY(:,2), 'ok', 'MarkerSize', 7)
end


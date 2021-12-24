function [ spec,treeName] = getRatioSpecificType( skel,trees,specName )
%getSpecificityPlot create Specificity plot of annotated trees
% INPUT trees: [1xN] vector of linear indices

% OUTPUT
%Author: Ali Karimi<ali.karimi@brain.mpg.de>
treeName = cell(size(trees,2),1);
for i = 1:size( trees,2)
    tr=trees(i);
    treeName(i) = skel.names(tr);
    seedSy = skel.getNodesWithComment('seed', tr,'partial');
    unsureSy = skel.getNodesWithComment('unsure', tr, 'partial');
    allSy=skel.getNodesWithComment('sy',tr,'partial');
    specificSy = skel.getNodesWithComment(specName,tr,'partial');
    %remove seed and unsure synapses
    specificSy= setdiff(setdiff (specificSy,unsureSy),seedSy);
    allSy=setdiff(setdiff (allSy,unsureSy),seedSy);
    nrSpecifcSy(i) = size(specificSy,1);
    nrAllSy(i) = size(allSy,1);
end

spec=arrayfun(@(x,y) x/y, nrSpecifcSy,nrAllSy);
end


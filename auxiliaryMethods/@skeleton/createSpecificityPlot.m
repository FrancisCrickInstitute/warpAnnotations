function h = createSpecificityPlot(skel,trees,targetNames,individual,color,savingDir)
%getSpecificityPlot create Specificity plot of annotated trees
% INPUT trees: [1xN] vector of linear indices
%       
%       targetNames: {1xN} cell array of specifying the comment (even
%       partially) used for annotation of a specific target. The seed
%       synapse and the unsure synapses are excluded.
%       
%       individual:(Optional) Logical specifying whether the plot should get the
%       average of all trees(false) or plot axons individually(true)
%       (Default =false)
%       
%       color: (Optional) the color used for plotting
%       (Default =blue)
%
%       savingDir: (Optional) Dir used to save the excel sheet of
%       specificities
% 
% OUTPUT h: the plotting object (Errorbar/lineArray) 
% Author: Ali Karimi <ali.karimi@brain.mpg.de>


if ~exist('color','var') || isempty(color)
    color = 'b';
end

if ~exist('individual','var') || isempty(individual)
    individual = false;
end

if ~exist('savingDir','var') || isempty(savingDir)
    savingExcel =false;
else
    savingExcel =true;
end
treeName = cell(size(trees,2),1);
nrSpecifcSy = zeros(size(trees,2),size(targetNames,2));
i = 1;
for tr = trees
    treeName(i) = skel.names(tr);
    seedSy = skel.getNodesWithComment('seed', tr,'partial');
    unsureSy = skel.getNodesWithComment('unsure', tr, 'partial');
    for j = 1:size(targetNames,2)
        allSpecificSy = skel.getNodesWithComment(targetNames{j},tr,'partial'); 
        %remove seed and unsure synapses
        specificSy= setdiff(setdiff (allSpecificSy,unsureSy),seedSy);
        nrSpecifcSy(i,j) = size(specificSy,1);
    end 
    i = i+1;
end
nrAllSy = repmat(sum(nrSpecifcSy,2),[1,size(targetNames,2)]);
ratioSy = arrayfun(@(x,y) x/y, nrSpecifcSy,nrAllSy);

%writing specificity to excel file
if savingExcel
ratioWithNames = sortrows(cat(2,treeName,num2cell(ratioSy)));
ratioWithNamesCategories = cat(1,{'',targetNames{:}},ratioWithNames);
if ~isdir(fullfile(savingDir,'excelsheets'))
    mkdir(fullfile(savingDir,'excelsheets'))
end
xlswrite(fullfile(savingDir,'excelsheets',[treeName{1},'.xlsx']),ratioWithNamesCategories);
end

% plottng
if individual
    h= plot(1:size(targetNames,2),ratioSy','Color',color);
    ylabel('Individual Specificity');
else
avg = mean (ratioSy,1);
error = std(ratioSy)/sqrt(size(ratioSy,1));
h = errorbar(avg,error);
h.Color =color;
ylabel('Average Specificity');
end
set(gca,'XTick',1:size(targetNames,2),'XTickLabel',targetNames,'XTickLabelRotation',45,'Fontsize',18);
xlabel('Targets');
ylim([0,1]);

end


function h = plotValue(skel, value, treeIndices, umScale, lineWidths)
%PLOT Simple line plot of Skeleton. Nodes are scaled with
% skel.scale.
% INPUT treeIndices:(Optional) [Nx1] vector of linear indices
%           of trees to check for. (Default: all trees)             
%       value: [Nx1] cell array of values which will be mapped on each tree  
%       umscale: (Optional, added by AK 20.02.2017) logical if set true sets the scale to
%           micrometer. (Default: nanometer scale)
%       lineWidths: (Optional) Scalar or [Nx1] array specifying the line
%           widths for skeleton plots

% Author: Marcel Beining


% If no tree index is specified, plot all
if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end
if ~iscell(value)
    value = {value};
    if skel.numTrees() > 1 && numel(treeIndices) > 1
        warning('More trees in skeleton than value vectors defined')
    end
end

% If no color is specified, generate appropriate number of colors
% if ~exist('colors','var') || isempty(colors)
    colors = jet(101);
    colormap jet
% end


% Check um scale
if ~exist('umScale','var') || isempty(umScale) || umScale == 0
    scale = skel.scale;
else
    scale =skel.scale/1000;
end
if isempty(scale)
    scale = 1;
    warning('No scale given. Set to 1.')
end

% Check lineWidths
if ~exist('lineWidths','var')
    lineWidths = 1;
end
if length(lineWidths) < skel.numTrees()
   lineWidths = repmat(lineWidths(1),1,skel.numTrees()) ;
end
hold on
minVal = double(min(cellfun(@min,value)));
maxVal = double(max(cellfun(@max,value)));
if minVal == maxVal && maxVal == 0
    maxVal = 1;
end
% Generate plot
for tr = treeIndices
    thisValue = value{tr};
    if islogical(thisValue)
        thisValue = double(thisValue); % to convert logicals and avoid other problems
    end
    
    trNodes = bsxfun(@times,skel.nodes{tr}(:,1:3),scale);
    lineWidth = lineWidths(tr);
    for ed = 1:size(skel.edges{tr},1)
        edge = skel.edges{tr}(ed,:);
        if ~isnan(thisValue(edge(2)))
        h = plot3(trNodes(edge,1),trNodes(edge,2), ...
            trNodes(edge,3),...
            '-','Color',colors(round(thisValue(edge(2))/maxVal*100)+1,:),'LineWidth',lineWidth);
        end
    end
end
end
function h = plot(skel, treeIndices, colors, umScale, lineWidths,realEndingComments,unityScale,somaSize,somaComment)
%PLOT Simple line plot of Skeleton. Nodes are scaled with
% skel.scale.
% INPUT treeIndices:(Optional) [Nx1] vector of linear indices
%           of trees to check for. (Default: all trees)             
%       colors: (Optional) [Nx3] array of double specifying a colormap.  
%           (Default: colors = colormap(lines))
%       umscale: (Optional, added by AK 20.02.2017) logical if set true sets the scale to
%           micrometer. (Default: nanometer scale)
%       lineWidths: (Optional) Scalar or [Nx1] array specifying the line
%           widths for skeleton plots
%       realEndingComments:(Optional):1xN cell array specifying comments of
%       real tree endings. With this specification the tree would be
%       trimmed to its backbone. added by AK
%       unityScale: (Optional, added by SL) Logical if set to true keeps the
%       original scale [1 1 1]
%       somaSize: (Optional) Scalar with size of soma [in nm]. If not
%       given or the node has no 'soma' comment, no soma is plotted
%       somaComment: str of the comment name, Default: 'soma'
% OUTPUT h: structure array with each tree plot as an graphics object array as a fieldname treeId"Nr" (e.g.treeId1)
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
%         Ali Karimi <ali.karimi@brain.mpg.de>
%         Sahil Loomba <sahil.loomba@brain.mpg.de>
%         Marcel Beining <marcel.beining@brain.mpg.de>


% If no tree index is specified, plot all
if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end
if islogical(treeIndices)
    treeIndices = find(treeIndices);
end
if ~exist('somaComment','var') || isempty(somaComment)
    somaComment = 'soma';
end

if ~exist('somaSize','var') || isempty(somaSize)
    somaSize = 0;
else
    [comments, treeIdx, nodeIdx] = skel.getAllComments;
    somaNode = zeros(skel.numTrees,1);
    somaNode(treeIdx(strcmpi(comments,somaComment))) = nodeIdx(strcmpi(comments,somaComment));
end

% If no color is specified, generate appropriate number of colors
if ~exist('colors','var') || isempty(colors)
    colors = lines(numel(treeIndices));
end
% If a color matrix of insufficient size is passed enlarge it
if size(colors,1) < numel(treeIndices)
    colors = padarray(colors,numel(treeIndices)-size(colors,1),'circular',...
        'post');
end

% Check um scale
if ~exist('unityScale','var') || isempty(unityScale) || unityScale == 0
    if ~exist('umScale','var') || isempty(umScale) || umScale == 0
        if isempty(skel.scale)
            scale = [1,1,1];
            warning('No scale information found in skeleton. Using [1 1 1] as scale.')
        else
            scale = skel.scale;
        end
    else
        scale =skel.scale/1000;
    end
else
    scale = [1 1 1];
end

% Check lineWidths
if ~exist('lineWidths','var') || isempty(lineWidths)
    lineWidths = 1;
end
if length(lineWidths) == numel(treeIndices)
    tmp = lineWidths;
    lineWidths = zeros(skel.numTrees(),1);
    lineWidths(treeIndices) = tmp;
elseif length(lineWidths) < skel.numTrees()
   lineWidths = repmat(lineWidths(1),1,skel.numTrees()) ;
end
% Check if Backbone comments exist and Trim the tree if they do
if ~exist('realEndingComments','var') || isempty(realEndingComments)
    trim2BackBone=false;
else
    trim2BackBone=true;
end

% Generate plot
if iscolumn(treeIndices)
    treeIndices = treeIndices';
end
[sX,sY,sZ] = sphere;
%structure to gather the line objects for each tree as h.treeIndex
h=struct();
for tr = treeIndices
    if trim2BackBone
        skel=skel.getBackBone(tr,realEndingComments);
    end
    trNodes = bsxfun(@times,skel.nodes{tr}(:,1:3),scale);
    lineWidth = lineWidths(tr);
    h.(['treeId' num2str(tr)])=gobjects(size(skel.edges{tr},1),1);
    for ed = 1:size(skel.edges{tr},1)
        edge = skel.edges{tr}(ed,:);
        h.(['treeId',num2str(tr)])(ed,1) = plot3(trNodes(edge,1),...
            trNodes(edge,2), trNodes(edge,3),...
            '-','Color',colors(treeIndices==tr,:),'LineWidth',lineWidth);
        hold on
    end
    if somaSize && somaNode(tr)
        coord = skel.nodes{tr}(somaNode(tr),1:3).*scale;
        surf(sX*somaSize+coord(1),sY*somaSize+coord(2),sZ*somaSize+coord(3),'FaceColor',colors(treeIndices==tr,:),'EdgeColor','None')
    end
end

end

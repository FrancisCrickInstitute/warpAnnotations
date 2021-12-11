function [mainSkeleton,synapseObject]=plotWithSynapses( skel, treeIndices, syNameCell, umscale, varargin)
%PLOTWITHSYNAPSES Simple line plot of Skeleton plus synapses as scatter
% balls with the legend displaying their identity
% INPUT treeIndices: (Optional) [1*N] vector of linear indices
%                of trees to check for.
%                (Default: all trees)
%       syNameCell: {1*N} cell with the names of the synapse labels used
%           even partially, excluding the synapses having 'unsure' label
%           savingDir
%       umscale: (Optional, added by AK 20.02.2017) logical if set true
%           sets the scale to micrometer
%           (Default: nanometer scale)
%       varargin:
%          It can include 'cmap': colormap for synapse type, 'angle': The
%          viewing angle of, 'showLegend': logical to see the legend,
%          'showAxis': Logical to show axis or not,getSynCenterBackBone: if
%          set to true the center of synapse is chosen and the tree is
%          trimmed to its backbone.'bifurcation': creates two colors for the skeleton tracings
%           structure with fields color(1x2 cell with two RGBs,)and nameUL
%           (name for distinguishing uperlayer apicals).specific for AK
%           Example function call:
%           skel.plotWithSynapses(i,{'sh','sp'},true,'angle',[0 -90]...
%            ,'showLegend',false,'showAxis',false,'getSynCenterBackBone',true);

% Author: Ali Karimi <ali.karimi@brain.mpg.de>
%%rewrite with optIn, do this for all the 
optIn = struct;
optIn.bifurcation = [];
optIn.angle=[];
optIn.showLegend=true;
optIn.showAxis=true;
optIn.getSynCenter=false;
optIn.getBackBone=false;

optIn = Util.modifyStruct(optIn, varargin{:});
%Other paramater initializations
if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:skel.numTrees();
end

if ~exist('umscale','var') || isempty(umscale) || umscale == 0
    scale = skel.scale;
    umscale = 0;
else
    scale =skel.scale/1000;
end
if ~exist('syNameCell','var') || isempty(syNameCell)
    syNameCell = 'syn';
end
if ischar(syNameCell)
    syNameCell = {syNameCell};
end
if ~exist('bifurcation','var') || isempty(bifurcation)
    % give each tree a unique color
    skeletonColormap = lines(size(treeIndices,2));
else
    %Initialize all with the DL color
    skeletonColormap=repmat(bifurcation.color{1},[size(treeIndices,2),1]);
    % get the ul colors
    ulIds=find(cellfun(@(x) ~isempty(strfind(x,bifurcation.nameUL)),skel.names(treeIndices)));
    %repeat the ul colors so that it matches the number of ul trees that we
    %have
    ulColorRepeated=repmat(bifurcation.color{2},[size(ulIds,1),1]);
    skeletonColormap(ulIds,:)=ulColorRepeated;
    
end
% Decide whether to trim the skeleton to it's main backbone+spines or leave
% it as it is
if getBackBone
    mainSkeleton=skel.plot(treeIndices,skeletonColormap,umscale,2,{'exit','start',syNameCell{2}});
else
    mainSkeleton=skel.plot(treeIndices,skeletonColormap,umscale);
end
%   Plot the synapses here
synapseObject=skel.plotSynapses(treeIndices,syNameCell,scale,getSynCenter,cmap,[],[]);
%   Display the legend
if showLegend
    legend(synapseObject.(['treeId' num2str(treeIndices(1))]),'Location','northeast');
end
%Set the correct aspect ratio
daspect([1 1 1])
%Set the viewing angle
view(angle);
if size(treeIndices,2)==2
    title(regexprep(skel.names(treeIndices),'_','\\_'));
end
if showAxis
    %Add labels to axis
    if umscale
        xlabel('x (\mum)')
        ylabel('y (\mum)')
        zlabel('z (\mum)')
    else
        xlabel('x (nm)')
        ylabel('y (nm)')
        zlabel('z (nm)')
    end
else
    axis off;
end
end


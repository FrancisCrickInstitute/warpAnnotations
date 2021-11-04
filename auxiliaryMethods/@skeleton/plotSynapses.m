function [ synapseObject] = plotSynapses( skel,treeIndices,varargin)
%PLOTSYNAPSES Plots the synapses of multiple trees
%INPUT:
%       treeIndices: (Optional:all trees) Contains indices of trees for which the synapse are extracted
%       varargin: 
%       scale: 1x3 array scale used to transform voxel to physical
%       coordinate
%       theColormap:colormap used to give each synapse gtoup a specific
%       color (default lines)
%       sphereSize: radius of the sphere used for each synapse
%       For the rest Refer to getSynIdxComment doc
%OUTPUT:
%       synapseObject:structure with tree having it's own field within the
%                       field exists the object array for the scatter sphere
%                       use this to change properties outside the function
% Author: Ali Karimi <ali.karimi@brain.mpg.de>

% Setting defaults specific to plotSynapses
if ~exist('treeIndices','var') || isempty(treeIndices)
    treeIndices = 1:size(skel.nodes,1);
end
optIn.scale=skel.scale;
optIn.theColorMap=colormap(lines);
optIn.sphereSize=100;
optIn.syn={'sh','sp'};
optIn = Util.modifyStruct(optIn, varargin{:});


% Object to have the graphics handle for the scatter spheres
synapseObject=struct();
fieldNameFun=@(tr) (['treeId' num2str(tr)]);

% Get and scale synapse coordinates
synCoords=skel.getSynCoordComment( treeIndices, varargin{:});
synCoords(:,2:end)=cellfun(@(coords) skel.setScale(coords,optIn.scale)...
    ,synCoords(:,2:end).Variables,'UniformOutput',false);

hold on
% Going through all the trees to be plotted
counterTree=1;
for tr = treeIndices(:)'
    for syType =1:length(optIn.syn)
        thisSynCoords=synCoords{counterTree,syType+1}{1};
        % Initialize. the synapse object and coordinate table for this specific
        % tree
        synapseObject.(fieldNameFun(tr))=gobjects(size(optIn.syn));
        % Scatter plotting
        synapseObject.(fieldNameFun(tr))(syType) = ...
            scatter3(thisSynCoords(:,1),thisSynCoords(:,2),thisSynCoords(:,3)...
            ,optIn.sphereSize,'filled', 'MarkerEdgeColor', optIn.theColorMap(syType,:), ...
            'MarkerFaceColor', optIn.theColorMap(syType,:));
        % Set the displayName
        synapseObject.(fieldNameFun(tr))(syType).DisplayName = ...
            optIn.syn{syType};
    end
    counterTree=counterTree+1;
end
end


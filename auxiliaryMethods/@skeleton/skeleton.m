classdef skeleton
    %Skeleton Class representing a Skeleton tracing.

    properties
        nodes = {};
        nodesAsStruct = {};
        nodesNumDataAll = {};
        nodesTable = {};
        edges = {};
        parameters;
        thingIDs;
        names = {};
        colors = {};
        branchpoints;
        largestID = 0;
        scale;
        nodeOffset;
        verbose = true;
        filename = ''; %the filename without .nml
        groupId = [];
        groups = struct2table(struct('name', '', 'id', ...
                    [], 'parent', []));
    end

    methods
        function obj = skeleton(filename, justCloneParameters, nodeOffset, verbose, options)
            % Construct Skeleton class from nml file.
            % obj = Skeleton() returns an empty Skeleton object.
            %
            % obj = Skeleton(filename, justcloneparameters, nodeOffset)
            % requires the following inputs.
            % INPUT filename: Full path (including '.nml') to nml file.
            %       justCloneParameters: Only parameter struct is written to
            %                           skel object. (Default: false)
            %       nodeOffset: (Optional) Double specifying an offset to
            %           the x, y and z coordinates of all nodes.
            %           (Default: 1).
            %       verbose: (Optional) Debug messages and warnings
            %           (Default: true).
            % OUTPUT skel: A Skeleton object.
            %
            % NOTE nodeOffset should be set to 1 when reading or writing
            %      files made in webknossos due to the webknossos node
            %      offset.
            options.dummy = [];
            if nargin > 0
                if ~exist('justCloneParameters','var') ...
                        || isempty(justCloneParameters)
                    justCloneParameters = false;
                end
                if exist('verbose','var') && ~isempty(verbose)
                    obj.verbose = verbose;
                end
                if ~exist('nodeOffset','var') || isempty(nodeOffset)
                    nodeOffset = 1;
                elseif length(nodeOffset) ~= 1
                    error('NodeOffset must be a scalar.');
                end

                obj.nodeOffset = nodeOffset;
                if nodeOffset ~= 1 && obj.verbose
                    warning('Node offset is set to %d.', nodeOffset);
                end
                [~,obj.filename, ending] = fileparts(filename);
                if ~strcmpi(ending, '.nml')
                    filename = [filename '.nml'];
                end
                if ~exist(filename, 'file')
                    error('File %s does not exist.', filename);
                end

                temp = slurpNml(filename);

                if justCloneParameters
                    obj.parameters = temp.parameters;
                    obj.scale = structfun(@str2double, ...
                        obj.parameters.scale)';
                    return;
                end

                obj.thingIDs = zeros(length(temp.things.id),1);
                obj.groupId = nan(length(temp.things.id),1);
                obj.nodes = cell(length(temp.things.nodes),1);
                obj.edges = cell(length(temp.things.edges),1);
                obj.names = cell(length(temp.things.name),1);
                obj.colors = cell(length(temp.things.id),1);
                obj.nodesAsStruct = cell(length(temp.things.id),1);
                obj.nodesNumDataAll = cell(length(temp.things.id),1);

                tmax = zeros(length(temp.things.id),1);
                for i=1:length(temp.things.id)
                    % nodes
                    obj.nodes{i} = [ ...
                        temp.things.nodes{i}.x + nodeOffset, ...
                        temp.things.nodes{i}.y + nodeOffset, ...
                        temp.things.nodes{i}.z + nodeOffset, ...
                        temp.things.nodes{i}.radius];

                    % edges
                    [~, obj.edges{i}] = ismember( ...
                        [temp.things.edges{i}.source, ...
                        temp.things.edges{i}.target], ...
                        temp.things.nodes{i}.id);
                    
                    
                    obj.thingIDs(i) = temp.things.id(i);
                    obj.groupId(i) = temp.things.groupId(i);
                    obj.names{i} = temp.things.name{i};
                    obj.colors{i} = [ ...
                        temp.things.('color.r')(i), ...
                        temp.things.('color.g')(i), ...
                        temp.things.('color.b')(i), ...
                        temp.things.('color.a')(i)];

                    obj.nodesNumDataAll{i} = ...
                        [temp.things.nodes{i}.id, ...
                         temp.things.nodes{i}.radius, ...
                         temp.things.nodes{i}.x + nodeOffset, ...
                         temp.things.nodes{i}.y + nodeOffset, ...
                         temp.things.nodes{i}.z + nodeOffset, ...
                         temp.things.nodes{i}.inVp, ...
                         temp.things.nodes{i}.inMag, ...
                         temp.things.nodes{i}.time];

                    nodesNumDataAllToStr = arrayfun(@num2str, ...
                        obj.nodesNumDataAll{i}, 'UniformOutput', false);
                    
                    % NOTE(amotta): `parseNml` used to initialize all
                    % comments to empty strings. Let's replicate this here.
                    comment = arrayfun(@(x)'', ...
                        1:length(temp.things.nodes{i}.id), 'uni', 0)';
                   
                    [~, index] = ismember( ...
                       temp.things.nodes{i}.id, ...
                       temp.comments.node);
                    comment(index ~= 0) = ...
                       temp.comments.content(index(index ~= 0));
                    nodesNumDataAllToStr(:,9) = comment;
                    fieldNames = {'id', 'radius', 'x', 'y', 'z', ...
                        'inVp', 'inMag', 'time', 'comment'};
                    obj.nodesAsStruct{i} = ...
                        cell2struct(nodesNumDataAllToStr, fieldNames, 2)';

                    %handle empty trees (will produce warning below)
                    if ~isempty(obj.nodesNumDataAll{i})
                        tmax(i) = max(temp.things.nodes{i}.id);
                    end
                end
                if any(tmax == 0)
                    warning('Nml file %s contains empty trees.', filename);
                end
                obj.largestID = max(tmax);
                obj.groups = obj.flattenOrNestGroup(temp.groups);
                obj.parameters = temp.parameters;
                obj.branchpoints = temp.branchpoints.id;
                obj.scale = structfun(@str2double,obj.parameters.scale)';
            else %return empty Skeleton object
                obj.thingIDs = [];
                obj.nodes = {};
                obj.edges = {};
                obj.names = {};
                obj.colors = {};
                obj.nodesAsStruct = {};
                obj.nodesNumDataAll = {};
                obj.largestID = 0;
                obj.parameters = struct;
                obj.branchpoints = [];
                obj.scale = [];
                obj.nodeOffset = 1;
                obj.verbose = 0;
                obj.groupId = [];
            end
        end
    end

    methods (Static)
        [l,nl] = physicalPathLength(nodes, edges, voxelSize)
        [skel, treeOrigin] = loadSkelCollection(paths, nodeOffset, ...
            toCellOutput, addFilePrefix)
        skel = fromCellArray(c);
        skel = loadSkelCollectionFromSubfolders(paths, nodeOffset, ...
            toCellOutput)
        [scaledCoords]=setScale(coords,scale)
        resultsTable=synCellTableFun(fun,synapseTable)
    end
end

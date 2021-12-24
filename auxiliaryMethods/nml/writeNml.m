function writeNml( ksw_fname, ksw_skeleton, node_coordinate_offset )

% *******************************************************************************************************
% * writeNml.m                   NML creator for Knossos and webKnossos (Oxalis)                        *
% * Copyright 2013, 2014, 2015   Max Planck Institute for Brain Research, Frankfurt/Main                *
% * Version 1.14                 Martin Zauser                                                          *
% *******************************************************************************************************
VERSION = '1.17';

% WRITENML: Write Knossos or webKnossos (Oxalis) skeletons in Matlab as a .nml file
%
%   The function has the following arguments:
%       KSW_FNAME: Give the full path of the file in which you want to
%           write the data, e.g. 'E:\knossos_skeleton.nml'
%       KSW_SKELETON: Give the name of the cell array containing the
%           skeleton(s), e.g. tracing in the Matlab workspace.
%       NODE_COORDINATE_OFFSET: substract offset from every node coordinate before writing
%
%   for Knossos     => writeNml( 'E:\knossos_skeleton.nml', tracing )
%   for webKnossos  => writeNml( 'E:\knossos_skeleton.nml', tracing, 1 )
%

% version 1.01               Martin Zauser   comments are saved if available in the skeleton as a huge string
% version 1.02               Martin Zauser   comments are saved from nodesAsStruct attribute
% version 1.03               Martin Zauser   thingIDs and nodeIds corrected
%                                               (ID from nodesNumDataAll/nodesAsStruct instead of a sequential number)
% version 1.04               Martin Zauser   renamed to writeNml (former: writeKnossosNml),
%                                                output message informs about data source (nodes / nodesNumDataAll)
% version 1.05               Martin Zauser   writeNml terminates correctly in case nodesNumDataAll does not exist
%                                                or is empty
% version 1.06               Martin Zauser   branchpoint output is now available
% version 1.07               Martin Zauser   name attribute of thing element is provided in output file
% version 1.08               Martin Zauser   nodesAsStruct attribute can be cell or matrix struct
% version 1.09               Martin Zauser   bugfix: empty comments are now allowed
% version 1.10               Martin Zauser   works also for simple skeletons without nodesAsStruct
% version 1.11   24.03.2015  Martin Zauser   adaption for e2006 (parameters time, activeNode and editPosition optional)
% version 1.12   27.09.2015  Martin Zauser   function parameter 'node_coordinate_offset' added
% version 1.13   27.07.2016  Kevin Boergens  add rotational values
% version 1.14   14.10.2016  Martin Zauser   bugfix: time in column 14 (instead of 8) in nodesNumDataAll
% version 1.15   18.07.2017  Marcel Beining  made it possible to set skeleton parameter input as numbers instead of strings
% version 1.16   26.07.2017  Marcel Beining  automatic rounding of non-integer coordinates
% version 1.17   15.06.2018  Benedikt Staffler - add groups

% print version on the screen
fprintf( 'This is writeNml version %s, Copyright 2016 MPI for Brain Research, Frankfurt.\n', VERSION );

% Open the file, if it already exists, overwrite the contents.
fid = fopen( ksw_fname, 'w' );

% The .nml format is an ASCII file, thus human readable.
fprintf( fid, '<?xml version=\"1.0\"?>\n' );
fprintf( fid, '<things>\n' );

% If ksw_skeleton{1}.parameters is a structure array, continue.
if isfield( ksw_skeleton{1}, 'parameters' )
    
    % Read out the necessary information and write the parameters into the output file
    ksw_experimentName = ksw_skeleton{1}.parameters.experiment.name;
    if isfield(ksw_skeleton{1}.parameters.experiment, 'description')
        ksw_experimentDescription = ksw_skeleton{1}.parameters.experiment.description;
    else
        ksw_experimentDescription = '';
    end
    ksw_scale = ksw_skeleton{1}.parameters.scale;
    if isnumeric(ksw_scale.x)
        ksw_scale.x = num2str(ksw_scale.x);
        ksw_scale.y = num2str(ksw_scale.y);
        ksw_scale.z = num2str(ksw_scale.z);
    end
    ksw_offset = ksw_skeleton{1}.parameters.offset;
    if isnumeric(ksw_offset.x)
        ksw_offset.x = num2str(ksw_offset.x);
        ksw_offset.y = num2str(ksw_offset.y);
        ksw_offset.z = num2str(ksw_offset.z);
    end
    
    if isfield(ksw_skeleton{1}.parameters, 'userBoundingBox')
        % assume bbox is in format
        % [leftX, leftY, leftZ, width, height, depth]
        kws_bbox = ksw_skeleton{1}.parameters.userBoundingBox;
        bbox_str = sprintf(['\n\t\t<userBoundingBox ' ...
            'topLeftX="%s" topLeftY="%s" topLeftZ="%s" ' ...
            'width="%s" height="%s" depth="%s" />'], ...
            kws_bbox.topLeftX, kws_bbox.topLeftY, kws_bbox.topLeftZ, ...
            kws_bbox.width, kws_bbox.height, kws_bbox.depth);
    else
        bbox_str = '';
    end
    
    fprintf( fid, ...
        ['\t<parameters>\n\t\t' ...
        '<experiment name=\"%s\" description=\"%s\"/>\n\t\t' ...
        '<scale x=\"%s\" y=\"%s\" z=\"%s\"/>\n\t\t' ...
        '<offset x=\"%s\" y=\"%s\" z=\"%s\"/>' ...
        '%s'], ... % bbox str
        ksw_experimentName, ksw_experimentDescription, ...
        ksw_scale.x, ksw_scale.y, ksw_scale.z, ...
        ksw_offset.x, ksw_offset.y, ksw_offset.z, ...
        bbox_str);
    clear( 'ksw_experimentName', 'ksw_scale', 'ksw_offset');
    
    % optional parameters
    if isfield( ksw_skeleton{1}.parameters, 'time' )
        ksw_time = ksw_skeleton{1}.parameters.time.ms;
        if isnumeric(ksw_time)
            ksw_time = num2str(ksw_time);
        end
        fprintf( fid, '\n\t\t<time ms=\"%s\"/>', ksw_time );
        clear( 'ksw_time' );
    end
    if isfield( ksw_skeleton{1}.parameters, 'activeNode' )
        ksw_activeNode = ksw_skeleton{1}.parameters.activeNode.id;
        if isnumeric(ksw_activeNode)
            ksw_activeNode = num2str(ksw_activeNode);
        end
        fprintf( fid, '\n\t\t<activeNode id=\"%s\"/>', ksw_activeNode );
        clear( 'ksw_activeNode' );
    end
    if isfield( ksw_skeleton{1}.parameters, 'editPosition' )
        ksw_editPosition = ksw_skeleton{1}.parameters.editPosition;
        if isnumeric(ksw_editPosition.x)
            ksw_editPosition.x = num2str(ksw_editPosition.x);
            ksw_editPosition.y = num2str(ksw_editPosition.y);
            ksw_editPosition.z = num2str(ksw_editPosition.z);
        end
        
        fprintf( fid, '\n\t\t<editPosition x=\"%s\" y=\"%s\" z=\"%s\"/>',...
            ksw_editPosition.x, ksw_editPosition.y, ksw_editPosition.z );
        clear( 'ksw_editPosition' );
    end
    if isfield( ksw_skeleton{1}.parameters, 'zoomLevel' )
        ksw_zoomLevel = ksw_skeleton{1}.parameters.zoomLevel.zoom;
        if isnumeric(ksw_zoomLevel)
            ksw_zoomLevel = num2str(ksw_zoomLevel);
        end
        fprintf( fid, '\n\t\t<zoomLevel zoom=\"%s\"/>', ksw_zoomLevel );
        clear( 'ksw_zoomLevel' );
    end
    
    % Write end tag into the file.
    fprintf( fid, '\n\t</parameters>\n' );
end

% get offset (third parameter) if available
if nargin<3
    node_coordinate_offset = 0;
end
if round(node_coordinate_offset) ~= node_coordinate_offset
    warning('node_coordinate_offset is not in whole numbers! This might make problems in loading the nml.')
end

% Necessary if multiple skeletons exist.
kl_totalNodeC = 0;

% reset variables for data source message and for nodesAsStruct
thing1_available = 0;
thing2_available = 0;
thing1_start = 0;
thing1_end = 0;
thing2_start = 0;
thing2_end = 0;
nodesAsStructIsCell = 0;
% reset ID offset
nodeIDoffset = 0;
% time base is available (default)
time_base = 1;

% Determine the number of different skeletons and go over each one.
for kl_thingC = 1 : numel( ksw_skeleton)
    
    % Check if nodesAsStruct exists
    nodesAsStructExists = 0;
    if isfield( ksw_skeleton{kl_thingC}, 'nodesAsStruct' ) &&...
            ~isempty( ksw_skeleton{kl_thingC}.nodesAsStruct )
        nodesAsStructExists = 1;
    end
    
    % Check if nodesAsStruct is a cell or a matrix struct (check property of first tree)
    if kl_thingC == 1
        if nodesAsStructExists
            nodesAsStructIsCell = iscell( ksw_skeleton{1}.nodesAsStruct );
        end
    end
    
    % get tree ID
    if isfield( ksw_skeleton{kl_thingC}, 'thingID' ) && ...
            ~isempty( ksw_skeleton{kl_thingC}.thingID )
        thingID = ksw_skeleton{kl_thingC}.thingID;
    else
        thingID = kl_thingC;
    end
    
    % Start with writing the skeleton ("thing") id into the file.
    fprintf( fid, '\t<thing id=\"%d\"', thingID );
    % Write name attribute if available
    if isfield( ksw_skeleton{kl_thingC}, 'name' ) &&...
            ~isempty( ksw_skeleton{kl_thingC}.name )
        fprintf( fid, ' name=\"%s\"', ksw_skeleton{kl_thingC}.name );
    end
    % Write color attribute(s) if available
    if isfield( ksw_skeleton{kl_thingC}, 'color' )
        fprintf( fid, ' color.r=\"%d\" color.g=\"%d\" color.b=\"%d\" color.a=\"%d\"',...
            ksw_skeleton{kl_thingC}.color(1), ksw_skeleton{kl_thingC}.color(2), ...
            ksw_skeleton{kl_thingC}.color(3), ksw_skeleton{kl_thingC}.color(4));
    end
    
    if isfield(ksw_skeleton{kl_thingC}, 'groupId') && ...
       ~isnan(ksw_skeleton{kl_thingC}.groupId)
        fprintf(fid, ' groupId=\"%d\"', ksw_skeleton{kl_thingC}.groupId);
    end
    
    fprintf( fid, '>\n' );
    % Write the nodes of the skeleton into the file.
    fprintf( fid, '\t\t<nodes>\n' );
    
    if isfield( ksw_skeleton{kl_thingC}, 'nodesNumDataAll' ) &&...
            ~isempty( ksw_skeleton{kl_thingC}.nodesNumDataAll )
        
        ksw_nodeList = ksw_skeleton{kl_thingC}.nodesNumDataAll;
        
        if any(any(round(ksw_nodeList(:,3:5))~=ksw_nodeList(:,3:5)))
            ksw_nodeList(:,3:5) = round(ksw_nodeList(:,3:5));
            warning('Coordinate list of skeleton %d was not in whole numbers. Values were rounded!',kl_thingC)
        end
        % write node list into file (include time if it is available)
        if size( ksw_nodeList, 2 ) > 7
            % rotation is available (column 8, 9, 10)
            % add empty time value if necessary (column 14)
            if size( ksw_nodeList, 2 ) < 14
                ksw_nodeList( 1, 14 ) = 0;
            end
            for ksw_c = 1 : size( ksw_nodeList, 1 )
                fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"%d\" inMag=\"%d\" rotX=\"%f\" rotY=\"%f\" rotZ=\"%f\" time=\"%d\"/>\n', ...
                    ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_c, 1 ), ...
                    ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) - node_coordinate_offset, ...
                    ksw_nodeList( ksw_c, 4 ) - node_coordinate_offset, ksw_nodeList( ksw_c, 5 ) - node_coordinate_offset, ...
                    ksw_nodeList( ksw_c, 6 ), ksw_nodeList( ksw_c, 7 ), ksw_nodeList( ksw_c, 8 ), ...
                    ksw_nodeList( ksw_c, 9 ), ksw_nodeList( ksw_c, 10 ), ksw_nodeList( ksw_c, 14 ) );
            end
            time_base = 1;
        else
            % time is not available => set time value to zero
            for ksw_c = 1 : size( ksw_nodeList, 1 )
                fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"%d\" inMag=\"%d\" time=\"%d\"/>\n', ...
                    ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_c, 1 ), ...
                    ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) - node_coordinate_offset, ...
                    ksw_nodeList( ksw_c, 4 ) - node_coordinate_offset, ksw_nodeList( ksw_c, 5 ) - node_coordinate_offset, ...
                    ksw_nodeList( ksw_c, 6 ), ksw_nodeList( ksw_c, 7 ), 0 );
            end
            time_base = 0;
        end
        % get data source information
        if thing1_available == 0
            thing1_start = thingID;
            thing1_end = thingID;
            thing1_available = 1;
        else
            if thingID < thing1_start
                thing1_start = thingID;
            end
            if thingID > thing1_end
                thing1_end = thingID;
            end
        end
        
    else
        
        ksw_nodeList = ksw_skeleton{kl_thingC}.nodes;
        
        if any(any(round(ksw_nodeList(:,1:3))~=ksw_nodeList(:,1:3)))
            ksw_nodeList(:,1:3) = round(ksw_nodeList(:,1:3));
            warning('Coordinate list of skeleton %d was not in whole numbers. Values were rounded!',kl_thingC)
        end
        % Write each node successively into the file.
        %   write only if nodesAsStruct exists
        %   if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
        %                    otherwise use ...nodesAsStruct(ksw_c)...
        if ~nodesAsStructExists
            for ksw_c = 1 : size( ksw_nodeList, 1 )
                % write nodes (all four parameters are zero => node is empty and will not be written)
                if (ksw_nodeList( ksw_c, 1 ) ~= 0) || (ksw_nodeList( ksw_c, 2 ) ~= 0) || ...
                        (ksw_nodeList( ksw_c, 3 ) ~= 0) || (ksw_nodeList( ksw_c, 4 ) ~= 0)
                    fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"0\" inMag=\"0\" time=\"0\"/>\n', ...
                        ksw_c + nodeIDoffset, ...
                        ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ) - node_coordinate_offset, ...
                        ksw_nodeList( ksw_c, 2 ) - node_coordinate_offset, ksw_nodeList( ksw_c, 3 ) - node_coordinate_offset );
                end
            end
        else
            if nodesAsStructIsCell
                for ksw_c = 1 : size( ksw_nodeList, 1 )
                    fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"0\" inMag=\"0\" time=\"0\"/>\n', ...
                        str2double( ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id ), ...
                        ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ) - node_coordinate_offset, ...
                        ksw_nodeList( ksw_c, 2 ) - node_coordinate_offset, ksw_nodeList( ksw_c, 3 ) - node_coordinate_offset );
                end
            else
                for ksw_c = 1 : size( ksw_nodeList, 1 )
                    fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"0\" inMag=\"0\" time=\"0\"/>\n', ...
                        str2double( ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id ), ...
                        ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ) - node_coordinate_offset, ...
                        ksw_nodeList( ksw_c, 2 ) - node_coordinate_offset, ksw_nodeList( ksw_c, 3 ) - node_coordinate_offset );
                end
            end
        end
        % get data source information
        if thing2_available == 0
            thing2_start = thingID;
            thing2_end = thingID;
            thing2_available = 1;
        else
            if thingID < thing2_start
                thing2_start = thingID;
            end
            if thingID > thing2_end
                thing2_end = thingID;
            end
        end
        
    end
    
    fprintf( fid, '\t\t</nodes>' );
    
    % Start with writing the edges into the file. If the matrix does
    % not exist or is empty, simply write 'edges' into the file.
    if ~isfield( ksw_skeleton{kl_thingC}, 'edges' ) || isempty( ksw_skeleton{kl_thingC}.edges )
        fprintf( fid, '\n\t\t<edges/>' );
        
        % If edges is a structure array, write the edges successively into
        % the file.
    else
        fprintf( fid, '\n\t\t<edges>\n' );
        
        if ~nodesAsStructExists
            for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                fprintf( fid, '\t\t\t<edge source=\"%d\" target=\"%d\"/>\n', ...
                    ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ) + nodeIDoffset, ...
                    ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ) + nodeIDoffset);
            end
        else
            if isfield( ksw_skeleton{kl_thingC}, 'nodesNumDataAll' ) && ~isempty( ksw_skeleton{kl_thingC}.nodesNumDataAll )
                for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                    fprintf( fid, '\t\t\t<edge source=\"%d\" target=\"%d\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ), 1), ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ), 1) );
                end
            else
                for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                    fprintf( fid, '\t\t\t<edge source=\"%s\" target=\"%s\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesAsStruct{ ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ) }.id, ...
                        ksw_skeleton{kl_thingC}.nodesAsStruct{ ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ) }.id );
                end
            end
        end
        
        fprintf( fid, '\t\t</edges>' );
    end
    
    % Change kl_totalNodeC to let the node id start at the right number
    % if multiple skeletons exist.
    kl_totalNodeC = kl_totalNodeC + size( ksw_nodeList, 1 );
    fprintf( fid, '\n\t</thing>\n' );
    
    % calculate ID offset (only necessary if nodesAsStruct and therefore single IDs do not exist)
    nodeIDoffset = nodeIDoffset + size( ksw_nodeList, 1 );
end

% Check if nodesAsStruct of the first tree exists
%  => for writing comments the existence of nodesAsStruct of the first tree iss essential
nodesAsStructExists = 0;
if isfield( ksw_skeleton{kl_thingC}, 'nodesAsStruct' ) && ~isempty( ksw_skeleton{1}.nodesAsStruct )
    nodesAsStructExists = 1;
end

% print data source information
% -----------------------------
if thing1_available ~= 0
    fprintf( 'Data source (thing %d', thing1_start );
    if thing1_end ~= thing1_start
        fprintf( '-%d', thing1_end );
    end
    if time_base
        fprintf( '): nodesNumDataAll -> id,radius,x,y,z,inVp,inMap,time\n' );
    else
        fprintf( '): nodesNumDataAll -> id,radius,x,y,z,inVp,inMap\n' );
    end
end
if thing2_available ~= 0
    fprintf( 'Data source (thing %d', thing2_start );
    if thing2_end ~= thing2_start
        fprintf( '-%d', thing2_end );
    end
    fprintf( '): nodesAsStruct -> id  /  nodes -> radius,x,y,z\n' );
end

% version 1.06
% Write branchpoints (all branchpoints are attached to the first cell element)
if isfield( ksw_skeleton{1}, 'branchpoints' ) && ~isempty( ksw_skeleton{1}.branchpoints )
    fprintf( fid, '\t<branchpoints>\n' );
    for ksw_c = 1 : size( ksw_skeleton{1}.branchpoints, 1 )
        fprintf( fid, '\t\t<branchpoint id=\"%d\"/>\n', ...
            ksw_skeleton{1}.branchpoints( ksw_c ) );
    end
    fprintf( fid, '\t</branchpoints>\n' );
end

% version 1.02   comments are saved from NodesAsStruct attribute
% Write the comments in nodesAsStruct into the file (if nodesAsStruct exists)
% first run: get ids of comments
numberOfComments = 0;
% if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
%                  otherwise use ...nodesAsStruct(ksw_c)...
if nodesAsStructExists
    if nodesAsStructIsCell
        for kl_thingC = 1 : size( ksw_skeleton, 2 )
            for ksw_c = 1 : size( ksw_skeleton{kl_thingC}.nodesAsStruct, 2 )
                if ~strcmp( ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.comment, '' )
                    if numberOfComments == 0
                        % create first comment
                        commentIds = [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id) kl_thingC ksw_c];
                    else
                        % append following comments
                        commentIds = vertcat( commentIds, [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id) kl_thingC ksw_c] );
                    end
                    numberOfComments = numberOfComments + 1;
                end
            end
        end
    else
        for kl_thingC = 1 : size( ksw_skeleton, 2 )
            for ksw_c = 1 : size( ksw_skeleton{kl_thingC}.nodesAsStruct, 2 )
                if ~strcmp( ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).comment, '' )
                    if numberOfComments == 0
                        % create first comment
                        commentIds = [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id) kl_thingC ksw_c];
                    else
                        % append following comments
                        commentIds = vertcat( commentIds, [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id) kl_thingC ksw_c] );
                    end
                    numberOfComments = numberOfComments + 1;
                end
            end
        end
    end
end
% write comments into file
if numberOfComments == 0
    % no comments
    fprintf( fid, '\t<comments> </comments>\n' );
else
    % sort comments by node id
    commentIdsSorted = sortrows(commentIds, 1);
    % second run: store ids
    fprintf( fid, '\t<comments>\n' );
    % if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
    %                  otherwise use ...nodesAsStruct(ksw_c)...
    if nodesAsStructExists
        if nodesAsStructIsCell
            for comments_c = 1 : numberOfComments
                fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
                    commentIdsSorted( comments_c, 1 ), ...
                    ksw_skeleton{commentIdsSorted( comments_c, 2 )}.nodesAsStruct{commentIdsSorted( comments_c, 3 )}.comment );
            end
        else
            for comments_c = 1 : numberOfComments
                fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
                    commentIdsSorted( comments_c, 1 ), ...
                    ksw_skeleton{commentIdsSorted( comments_c, 2 )}.nodesAsStruct(commentIdsSorted( comments_c, 3 )).comment );
            end
        end
    end
    fprintf( fid, '\t</comments>\n' );
end

% write groups into file
if isfield(ksw_skeleton{1}, 'groups')
    groups = ksw_skeleton{1}.groups;
    hasGroups = ~isempty(groups.id);
    if ~hasGroups
        fprintf(fid, '<groups />\n');
    else
        fprintf(fid, '<groups>');
        fprintf(fid, generateGroupTags(groups));
        fprintf(fid, '</groups>\n');
    end
end
    

% Write the last line, then close the file.
fprintf( fid, '</things>\n' );
fclose( fid );

% Print message onto screen.
fprintf( 'Done writing!\n' );

end

function str = generateGroupTags(groups)
str = '';
for i = 1:length(groups.name)
    % use sprintf everywhere to avoid removing of \n
    if isempty(groups.children{i})
        str = sprintf('%s<group name=\"%s\" id=\"%d\" />\n', ...
            str, groups.name{i}, groups.id(i));
    else
        str = sprintf('%s<group name=\"%s\" id=\"%d\">\n', ...
            str, groups.name{i}, groups.id(i));
        str = sprintf('%s%s', str, generateGroupTags(groups.children{i}));
        str = sprintf('%s</group>\n', str);
    end
end
end
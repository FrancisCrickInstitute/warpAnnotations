%PARSENML Parsing of nml files.
% skel = PARSENML(nmlPath) parses the nml-file at path.
% skel is a cell array with one cell for each tree in the nml file.
% Each cell contains a struct with the nodes and edges of the corresponding
% tree. The fields in each struct are:
%       'parameters': Struct containing information about the underlying
%           data and some webknossos related information.
%           (Note: 'parameters' is only saved for the first cell in skel.)
%       'nodes': [Nx4] array of double. Each row contains the x, y and z
%           coordinate of a node in the first three columns and the radius
%           in the fourth column.
%       'nodesAsStruct': Cell array of length number of nodes in tree or
%           struct array of same length. The i-th cell or struct
%           respectively contains more detailed information about the node in
%           the i-th row of 'nodes'.
%       'nodesNumDataAll': [Nx9] array of double. Each row contains the
%           following information about a single node in the tree:
%           [id, radius, x, y, z, inVp, inMag, time]
%           The i-th row in 'nodesNumDataAll' corresponds to the i-th row
%           in 'nodes' and the i-th cell in 'nodesAsStruct'.
%       'edges': [Nx2] array of double. Each row constitutes an
%           (undirected) edge between the two nodes with the given indices.
%           The node indices correspond to cells in 'nodesAsStruct'
%           (respectively the rows in 'nodes' and 'nodesNumDataAll') and
%           NOT to the id of the nodes. The number of rows of 'edges'
%           should always be one less than the number of rows in 'nodes'.
%       'thingID': The unique tree id.
%       'name': The name of the tree.
%       'commentString': The nml file comments tag with its whole content
%           as a string. (Note: 'commentString' is only saved for the first cell
%           in skel.)
%       'branchpointString' All branchpoint tags of the nml file as a
%           single string. (Note: 'branchpointString' is only saved for the
%            first cell in skel.)
%       'branchpoints': [Nx1] array of double containing the ids of all
%           branchpoint nodes. (Note: 'branchpoints' is only saved for the
%            first cell in skel.)
%
% skel = PARSENML(nmlPath,keepNodeAsStruct,nodesAsStructIsCell,useInVp,nodeCoordinateOffset)
% Additional parameters are:
%   keepNodesAsStruct: Flag (0, 1) indicating whether to calculate the
%       nodesAsStruct field.
%   nodesAsStructIsCell: Flag (0, 1) indicating whether 'nodesAsStruct'
%       should be a cell array of structs or a struct array.
%   useInVP: Flag (0,1) indicating whether inVP, inMag and time should be
%       parsed as well.
%   nodeCoordinateOffset: Double specifying an offset to the x, y and z
%       coordinates of all nodes.
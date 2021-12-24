function nodeTable = buildNodeTable(nml)
    things = nml.things;
    nodes = things.nodes;
    
    nodeTable = cellfun( ...
        @(n) {struct2table(n)}, nodes);
    
    % add tree ids to node table
    nodeTable = arrayfun( ...
        @addThingId, nodeTable, things.id);
    
    % get all nodes
    nodeTable = vertcat(nodeTable{:});
    
    % make coordinate table
    nodeTable.coord = [ ...
        nodeTable.x, ...
        nodeTable.y, ...
        nodeTable.z];
    
    % remove old fields
    nodeTable.x = [];
    nodeTable.y = [];
    nodeTable.z = [];
end

function nodes = addThingId(nodesCell, treeId)
    nodes = nodesCell{:};
    nodeCount = size(nodes, 1);
    
    % build tree id vector
    treeIdVec = nan(nodeCount, 1);
    treeIdVec(:) = treeId;
    
    % add to table
    nodes.treeId = treeIdVec;
    
    % make cell
    nodes = {nodes};
end
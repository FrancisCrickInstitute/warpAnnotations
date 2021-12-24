function box = getBoundingBox(nml)
    things = nml.things;
    thingNames = things.name;
    
    % find bounding box
    boxThingId = find(cellfun( ...
        @(s) strcmpi(s, 'bbox'), thingNames));
    boxNodes = nml.things.nodes{boxThingId};
    boxNodes = struct2table(boxNodes);
    
    % find lower and upper limit of box
    boxNodes.coord = [ ...
        boxNodes.x, boxNodes.y, boxNodes.z];
    boxMinVec = min(boxNodes.coord, [], 1);
    boxMaxVec = max(boxNodes.coord, [], 1);
    
    box = nan(3, 2);
    box(:, 1) = boxMinVec(:);
    box(:, 2) = boxMaxVec(:);
end
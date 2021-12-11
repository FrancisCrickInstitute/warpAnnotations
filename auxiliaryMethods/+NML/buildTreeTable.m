function trees = buildTreeTable(nml)
    things = nml.things;
    
    % make color table
    thingColorFields = strcat( ...
        'color.', {'r', 'g', 'b', 'a'});
    thingColors = arrayfun( ...
        @(c) {things.(c{:})}, thingColorFields);
    thingColors = horzcat(thingColors{:});
    
    % remove individual color fields
    things = rmfield(things, thingColorFields);
    things.color = thingColors;
    
    % build table
    trees = struct2table(things);
end
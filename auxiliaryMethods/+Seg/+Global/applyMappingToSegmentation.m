function applyMappingToSegmentation(p, mapping, outParam)
    sharedInArgs = {p.seg, outParam, mapping};
    inArgs = arrayfun(@(l) {{l.bboxSmall}}, p.local);
    
    job = Cluster.startJob( ...
        @doIt, inArgs, ...
        'sharedInputs', sharedInArgs, ...
        'cluster', {'memory', 12}, ...
        'name', mfilename());
    Cluster.waitForJob(job);
end

function doIt(inParam, outParam, mapping, bbox)
    data = loadSegDataGlobal(inParam, bbox);
    data(data ~= 0) = mapping(data(data ~= 0));
    saveSegDataGlobal(outParam, bbox(:, 1)', data);
end

function toVolume(param, nmlFile, outRoot)
    % toVolume(param, nmlFile, outRoot)
    %   Converts a merger mode tracing into a segmentation volume.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    nml = slurpNml(nmlFile);
    agglos = NML.buildAgglomerates(param, nml);
    
    % build mapping
    maxSegId = Seg.Global.getMaxSegId(param);
    mapping = Agglo.buildLUT(maxSegId, agglos);
    mapping = uint32(mapping);
    
    % build parameters
    inParam = param.seg;
    outParam = param.seg;
    outParam.root = outRoot;
    
    % run conversion
    taskArgsShared = {inParam, outParam, mapping};
    taskArgs = arrayfun(@(c) {{c.bboxSmall}}, param.local);
    
    job = Cluster.startJob( ...
        @doBox, taskArgs, 'sharedInputs', taskArgsShared, ...
        'cluster', {'taskConcurrency', 10}, 'name', mfilename);
    Cluster.waitForJob(job);
end

function doBox(inParam, outParam, mapping, box)
    % NOTE(amotta): Borders are not yet handled. It might be desireable to
    % fill them up using some kind of morphological operation.

    seg = loadSegDataGlobal(inParam, box);
    seg(seg > 0) = mapping(seg(seg > 0));
    saveSegDataGlobal(outParam, box(:, 1)', seg);
end

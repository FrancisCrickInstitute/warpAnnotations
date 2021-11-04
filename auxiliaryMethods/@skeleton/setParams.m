function skel = setParams(skel, expName, scale, offset)
    % Sets the dataset-specific parameters.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    assert(ischar(expName));
    assert(isnumeric(scale) && numel(scale) == 3);
    assert(isnumeric(offset) && numel(offset) == 3);
    
    skel.parameters.experiment.name = expName;
    
    skel.scale = reshape(scale, 1, 3);
    skel.parameters.scale.x = num2str(scale(1));
    skel.parameters.scale.y = num2str(scale(2));
    skel.parameters.scale.z = num2str(scale(3));
    
    skel.parameters.offset.x = num2str(offset(1));
    skel.parameters.offset.y = num2str(offset(2));
    skel.parameters.offset.z = num2str(offset(3));
end
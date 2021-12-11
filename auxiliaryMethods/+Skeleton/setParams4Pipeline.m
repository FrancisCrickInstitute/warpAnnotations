function skel = setParams4Pipeline(skel, param)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    skel = skel.setParams( ...
        param.experimentName, param.raw.voxelSize, [0, 0, 0]);
end
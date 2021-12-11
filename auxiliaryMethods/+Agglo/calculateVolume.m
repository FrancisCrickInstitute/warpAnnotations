function volumes = calculateVolume(param, agglos)
    % volumes = calculateVolume(param, agglos)
    %   Computes the volume (i.e. the number of voxels) for
    %   each agglomerates in agglo.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % case of single agglo
    if ~iscell(agglos)
        agglos = {agglos};
    end
    
    segToSizeMap = Seg.Global.getSegToSizeMap(param);
    volumes = cellfun(@(ids) sum(segToSizeMap(ids)), agglos);
    
    % make column vector
    volumes = volumes(:);
end

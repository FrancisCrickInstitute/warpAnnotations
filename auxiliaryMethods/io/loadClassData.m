function class = loadClassData(param, bbox)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~isfield(param, 'backend') || isempty(param.backend)
        % backward compatibility
        param.backend = 'wkcube';
    end

    switch param.backend
        case 'wkcube'
            class = readKnossosRoi( ...
                param.root, param.prefix, bbox, 'single');
        case 'wkwrap'
            class = wkwLoadRoi(param.root, bbox);
        otherwise
            error('Unknown backend ''%s''', param.backend);
    end
end


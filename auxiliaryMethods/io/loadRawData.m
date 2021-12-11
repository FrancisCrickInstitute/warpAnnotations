function raw = loadRawData(param, bbox)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~isfield(param, 'backend') || isempty(param.backend)
        % backward compatibility
        param.backend = 'wkcube';
    end
    
    switch param.backend
        case 'wkcube'
            raw = readKnossosRoi( ...
                param.root, param.prefix, bbox, 'uint8');
        case 'wkwrap'
            raw = wkwLoadRoi(param.root, double(bbox));
        otherwise
            error('Unknown backend ''%s''', param.backend);
    end
end 

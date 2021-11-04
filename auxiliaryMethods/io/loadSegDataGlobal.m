function seg = loadSegDataGlobal(param, bbox)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>

    if ~isfield(param, 'backend') || isempty(param.backend)
        % backward compatibility
        param.backend = 'wkcube';
    end

    switch param.backend
        case 'wkcube'
            seg = readKnossosRoi( ...
                param.root, param.prefix, bbox, 'uint32');
        case 'wkwrap'
            seg = wkwLoadRoi(param.root, bbox);
            if isfield(param,'channel')
                seg = squeeze(seg(param.channel,:,:,:));
            end
        otherwise
            error('Unknown backend ''%s''', param.backend);
    end
end


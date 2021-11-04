function saveClassData(param, offset, data)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~isfield(param, 'backend') || isempty(param.backend)
        % backward compatibility
        param.backend = 'wkcube';
    end
    
    if ~isa(data, 'single')
        % make sure we don't write nonsense to files
        error('Data has class ''%s''. Expected single.', class(data));
    end
    
    switch param.backend
        case 'wkcube'
            writeKnossosRoi( ...
                param.root, param.prefix, offset, data, 'single');
        case 'wkwrap'
            wkwSaveRoi(param.root, offset, data);
        otherwise
            error('Unknown backend ''%s''', param.backend);
    end
end
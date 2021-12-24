function saveSegDataGlobal(param, offset, data)
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    if ~isfield(param, 'backend') || isempty(param.backend)
        % backward compatibility
        param.backend = 'wkcube';
    end
    
    if ~isa(data, 'uint32')
        % make sure we don't write nonsense to files
        error('Data has class ''%s''. Expected uint32.', class(data));
    end
    
    switch param.backend
        case 'wkcube'
            writeKnossosRoi( ...
                param.root, param.prefix, offset, data, 'uint32');
        case 'wkwrap'
            wkwSaveRoi(param.root, offset, data);
        otherwise
            error('Unknown backend ''%s''', param.backend);
    end
end
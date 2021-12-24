function resp = putLabel3d(dvid, dataName, pos, data)
    % check data
    if ~isa(data, 'uint64')
        error('Grayscale data must be of type uint8');
    end
    
    % convert to byte sequence
    resp = dvid.putData3d(dataName, pos, data);
end
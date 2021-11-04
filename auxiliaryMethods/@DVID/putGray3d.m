function resp = putGray3d(dvid, dataName, pos, data)
    % check data
    if ~isa(data, 'uint8')
        error('Grayscale data must be of type uint8');
    end
    
    % convert to byte sequence
    resp = dvid.putData3d(dataName, pos, data);
end
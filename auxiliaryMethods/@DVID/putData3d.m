function resp = putData3d(dvid, dataName, pos, data)
    dataSize = size(data);
    sizeStr = dvid.vectorToString(dataSize);
    posStr = dvid.vectorToString(pos);
    
    % linearize data
    data = data(:);
    
    if ~isa(data, 'uint8')
        data = typecast(data, 'uint8');
    end
    
    urlParts = { ...
        dvid.getDataUrl(dataName), ...
        'raw', '0_1_2', sizeStr, posStr};
    url = strjoin(urlParts, '/');
    
    data = native2unicode(data, 'latin1');
    resp = dvid.sendPostRequest(url, data, 'binary');
end
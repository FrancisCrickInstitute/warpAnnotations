function resp = getData3d(dvid, dataName, pos, size)
    posStr = dvid.vectorToString(pos);
    sizeStr = dvid.vectorToString(size);
    
    urlParts = { ...
        dvid.getDataUrl(dataName), ...
        'raw', '0_1_2', sizeStr, posStr};
    url = strjoin(urlParts, '/');
    
    resp = dvid.sendGetRequest(url);
end
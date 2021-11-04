function resp = sendPostRequest(dvid, url, data, dataType)
    url = [dvid.getServerUrl(), url];
    
    % prepare options
    options = weboptions();
    options.RequestMethod = 'post';
    
    if strcmp(dataType, 'json')
        options.MediaType = 'application/json';
    elseif strcmp(dataType, 'binary')
        options.MediaType = 'application/octet-stream';
        options.CharacterEncoding = 'latin1';
    end
    
    resp = webwrite(url, data, options);
end
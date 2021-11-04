function resp = sendGetRequest(dvid, url, varargin)
    url = [dvid.getServerUrl(), url];
    
    % prepare options
    options = weboptions();
    resp = webread(url, varargin{:}, options);
end
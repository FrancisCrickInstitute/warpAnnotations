function uuid = createRepo(dvid, alias, description)
    postData = struct;
    
    if exist('alias', 'var')
        postData.alias = alias;
    end
    
    if exist('description', 'var')
        postData.description = description;
    end
    
    resp = dvid.sendPostRequest( ...
        'api/repos', postData, 'json');
    uuid = resp.root;
end
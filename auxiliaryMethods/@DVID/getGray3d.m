function resp = getGray3d(dvid, dataName, pos, size)
    % request data
    resp = dvid.getData3d(dataName, pos, size);
    
    % reshape if we've got that data
    if isa(resp, 'uint8')
        resp = reshape(resp, size);
    end
end
function resp = getLabel3d(dvid, dataName, pos, size)
    % request data
    resp = dvid.getData3d(dataName, pos, size);
    
    % reshape if we've got that data
    if isa(resp, 'uint8')
        resp = typecast(resp, 'uint64');
        resp = reshape(resp, size);
    end
end
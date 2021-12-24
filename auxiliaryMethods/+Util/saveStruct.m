function saveStruct(fileName, toSave)
    % Utility function for saving a structure to MAT file. It automatically
    % changes to V7.3 MAT files, if necessary.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    sizes = structfun(@byteSizeOf, toSave);

    if any(sizes >= 2 * (1024)^3)
        % only v7.3 supports variables larger than 2 GB
        save(fileName, '-struct', 'toSave', '-v7.3');
    else
        save(fileName, '-struct', 'toSave');
    end
end

function byteSize = byteSizeOf(in) %#ok
    byteSize = whos('in');
    byteSize = byteSize.bytes;
end
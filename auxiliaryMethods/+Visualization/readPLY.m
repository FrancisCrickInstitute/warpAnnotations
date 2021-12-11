function iso = readPLY(inFile)
    % iso = readPLY(inFile)
    %   Reads a mesh from a .PLY file.
    %
    % NOTE
    %   Written in a big hurry before the connectomics conference in 2017.
    %   It once worked - but only once. Use at your own risk!
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % find end of header
    header = readHeader(inFile);
    iso = readBody(inFile, header);
end

function iso = readBody(inFile, header)
    f = fopen(inFile, 'r', 'ieee-le');
    fseek(f, header.dataOff, 'bof');
    
    verts = fread(f, 3 * header.vertCount, 'single');
    
    facesLenOne = (1 + 3 * 4 + 4);
    facesLen = facesLenOne * header.faceCount;
    faces = fread(f, facesLen, 'uint8=>uint8');
    fclose(f);
    
    assert(all(faces(1:facesLenOne:end) == 3));
    faces(1:facesLenOne:end) = [];
    
    % get rid of patch indices
    faces = reshape(faces, 16, []);
    faces = faces(1:12, :);
    
    faces = typecast(faces(:), 'int32');
    faces = reshape(faces, 3, []);
    faces = transpose(faces);
    faces = double(faces) + 1;
    
    verts = transpose(reshape(verts, 3, []));
    
    iso = struct;
    iso.faces = faces;
    iso.vertices = verts;
end

function header = readHeader(inFile)
    needle = 'end_header';
    
    file = fileread(inFile);
    dataOff = strfind(file, needle);
    
    assert(not(isempty(dataOff)));
    header = file(1:(dataOff - 1));
    dataOff = dataOff + numel(needle) + 1;
    
    vertCount = readHeaderValue(header, 'element vertex');
    faceCount = readHeaderValue(header, 'element face');
    
    header = struct;
    header.dataOff = dataOff;
    header.vertCount = vertCount;
    header.faceCount = faceCount;
end

function val = readHeaderValue(header, fieldName)
    pos = strfind(header, fieldName);
    assert(not(isempty(pos)));
    
    header = header(pos:end);
    val = sscanf(header, strjoin({fieldName, '%u'}));
end
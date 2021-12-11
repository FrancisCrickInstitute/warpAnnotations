function writePLY(inMeshes, inMeshColours, outFile)
    % WRITEPLY Writes one or multiples meshes into a PLY
    % file. This function was orginally written for export
    % to Amira and Blender.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    % this script only work on processors
    % with little-endian memory layout
    [~, ~, endianness] = computer();
    
    if endianness ~= 'L'
        error('Little-endian only!');
    end
    
    % convert to cell
    if ~iscell(inMeshes);
        inMeshes = {inMeshes};
    end
    
    % sanity check
    numMeshes = numel(inMeshes);
    numColours = size(inMeshColours, 1);
    assert(numMeshes == numColours);
    
    % write file
    writePLYHeader(inMeshes, outFile);
    writePLYBody(inMeshes, inMeshColours, outFile);
end

function writePLYHeader(inMeshes, outFile)
    fh = fopen(outFile, 'w');
    
    % count elements
    vertCount = sum(cellfun( ...
        @(m) size(m.vertices, 1), inMeshes));
    faceCount = sum(cellfun( ...
        @(m) size(m.faces, 1), inMeshes));
    meshCount = numel(inMeshes);
    
    % print line function
    fprintln = @(str, varargin) ...
        fprintf(fh, [str, '\r\n'], varargin{:});
    
    % header
    fprintln('ply');
    fprintln('format binary_little_endian 1.0');
    
    % vertices
    fprintln('element vertex %u', vertCount);
    fprintln('property float32 x');
    fprintln('property float32 y');
    fprintln('property float32 z');
    
    % faces
    fprintln('element face %u', faceCount);
    fprintln('property list uint8 int32 vertex_indices');
    fprintln('property int32 patch');
    
    % patches
    fprintln('element patch %u', meshCount);
    fprintln('property int32 innerRegion');
    fprintln('property int32 outerRegion');
    
    % materials
    fprintln('element material %u', meshCount);
    fprintln('property int32 nparams');
    
    % parameters
    fprintln('element parameter %u', meshCount);
    fprintln('property list uint8 int8 name');
    fprintln('property list uint8 int8 parseString');
    
    fprintln('end_header');
    
    fclose(fh);
end

function writePLYBody(inMeshes, inMeshColours, outFile)
    meshCount = numel(inMeshes);
    
    % determine face offsets
    meshFaceOff = cellfun( ...
        @(m) size(m.vertices, 1), inMeshes);
    meshFaceOff = cumsum([0; meshFaceOff(:)]);
    
    % open file
    % - append at the end
    % - buffered writes (for performance)
    % - little endian ordering
    fh = fopen(outFile, 'A', 'ieee-le');

    % write vertices
    for meshIdx = 1:meshCount
        mesh = inMeshes{meshIdx};
        
        % to 32-bit floating points
        meshVerts = mesh.vertices;
        meshVerts = single(meshVerts);
        
        % write to file
        fwrite(fh, meshVerts', 'single', 'ieee-le');
    end
    
    % write faces
    for meshIdx = 1:meshCount
        mesh = inMeshes{meshIdx};
        
        % binary format for faces
        %
        % 1 bytes
        %   uint8 with number N of vertices
        % 4xN bytes
        %   zero-based indices of vertices, each one as
        %   little-endian int32
        % 4 bytes
        %   zero-based patch index as int32
        
        % to zero-based 32-bit signed ints
        meshFaces = mesh.faces;
        meshFaces = meshFaces - 1;
        meshFaces = meshFaces + meshFaceOff(meshIdx);
        meshFaces = int32(meshFaces);
        
        % count faces
        meshFaceCount = size(meshFaces, 1);
        
        % binary mesh idx
        meshIdxBin = int32(meshIdx - 1);
        meshIdxBin = typecast(meshIdxBin, 'uint8');
        meshIdxBin = meshIdxBin(:);
        
        % convert to binary
        meshFaces = meshFaces';
        meshFaces = typecast(meshFaces(:), 'uint8');
        meshFaces = meshFaces(:);
        
        meshFaces = [ ...
            repmat(uint8(3),    1, meshFaceCount);
            reshape(meshFaces, 12, meshFaceCount);
            repmat(meshIdxBin,  1, meshFaceCount)];
        meshFaces = meshFaces(:);
        
        % write output
        fwrite(fh, meshFaces, 'uint8');
    end
    
    % write patches
    %   Not sure what this is actually used for. I guess
    %   that these are zero-based indices of the colours
    %   that are to follow. The two sides of the triangle
    %   probably could have different colours.
    for meshIdx = 1:meshCount
        fwrite(fh, int32(meshIdx) - 1, 'int32', 'ieee-le');
        fwrite(fh, int32(meshIdx) - 1, 'int32', 'ieee-le');
    end
    
    % write matrials
    for meshIdx = 1:meshCount
        fwrite(fh, int32(1), 'int32', 'ieee-le');
    end
    
    % write colours
    for meshIdx = 1:meshCount
        % get colour
        meshColour = inMeshColours(meshIdx, :);
        
        % to string
        meshColourStr = [ ...
            sprintf('%1.2f', meshColour(1)), ' ', ...
            sprintf('%1.2f', meshColour(2)), ' ', ...
            sprintf('%1.2f', meshColour(3))];
        
        writePLYString(fh, 'Color');
        writePLYString(fh, meshColourStr);
    end
    
    fclose(fh);
end

function writePLYString(fh, str)
    % to binary
    strBin = [int8(str(:)); 0];
    strLen = numel(strBin);

    fwrite(fh, uint8(strLen), 'uint8');
    fwrite(fh,  int8(strBin),  'int8');
end
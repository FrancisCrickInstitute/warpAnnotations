function script = makeMappingScript(maxSegId, agglos, openTxt)
    % script = makeMappingScript(maxSegId, agglos)
    %   Builds a JavaScript snippet which dynamically
    %   produces the desired mapping in webKNOSSOS. This
    %   is an alternative to uploading JSON files.
    %
    % maxSegId
    %   Scalar. Largest global segment ID occuring. There
    %   must exist a more elegant solution than this...
    %
    % agglos
    %   Array of cell array. Each entry of the cell array
    %   contains the global IDs of all segments making up
    %   an equivalence class. If 'agglos' is a standard
    %   array, it will be considered as single equivalence
    %   class.
    %
    % script
    %   String. JavaScript snippet.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    if nargin < 3 || isempty(openTxt)
        openTxt = true;
    end
    if ~iscell(agglos)
        agglos = {agglos};
    end

    script = { ...
         'window.webknossos.apiReady(1).then((api) => {';
        ['  var mapping = Array(', num2str(maxSegId), ').fill(0);'];
         '  var agglos  = [];';
         makeAgglos(agglos);
         '';
         '  for(var i = 0; i < agglos.length; i++){';
         '    var segIds = agglos[i];';
         '    for(var j = 0; j < segIds.length; j++){';
         '        mapping[segIds[j]] = (i + 1);';
         '    }';
         '  }';
         '';
         '  api.data.setMapping("segmentation", mapping);';
         '});';};
    script = strjoin(script, '\n');

    % write to temporary file
    fileName = [tempname(), '.txt'];
    fileHandle = fopen(fileName, 'w');

    fwrite(fileHandle, script);
    fclose(fileHandle);

    % show in editor
    if openTxt
        try
            open(fileName);
        catch
            error('Could not open %s', fileName);
        end
    end
end

function arr = makeAgglos(agglos)
    arr = cellfun( ...
        @makeAggloArray, agglos, ...
        'UniformOutput', false);
    arr = strjoin(arr, '\n');
end

function arr = makeAggloArray(agglo)
    arr = arrayfun( ...
        @num2str, agglo, ...
        'UniformOutput', false);
    arr = ['  agglos.push([', strjoin(arr, ', '), ']);'];
end

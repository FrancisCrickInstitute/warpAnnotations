function nodes = load(param, nmlFile)
    % load(config, nmlFile)
    %   Loads the dense annotations from the NML file given by
    %   `nmlFile` and looks up the segment ID for each node. This
    %   function also generates a categorical label for each tree.
    %
    % Personal use-case
    %   I use this function to parse 'dense' annotations, which
    %   then serve as training data for the segment classifier. In
    %   each NML file, there are trees called 'Astrocyte', 'Axon',
    %   'Dendrite', 'SpineHead', etc. Optionally, each tree may
    %   also carry an additional suffix, which is separated by an
    %   underscore. The suffix is ignored when building the label.
    %
    % NOTE
    %   A segment may carry one or more categorical labels. You may
    %   want to call the function 'buildDenseLabels'.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    nml = slurpNml(nmlFile);
    
    trees = NML.buildTreeTable(nml);
    nodes = NML.buildNodeTable(nml);
    comments = NML.buildCommentTable(nml);
    
    % build tree ID → row mapping
    idToRowMap = buildIdToRowMap(trees);
    
    % convert tree names to lower case
    % and add them to each of the nodes
    trees.name = buildCategories(trees.name);
    nodes.label = trees.name(idToRowMap(nodes.treeId));
    
    % add comments to nodes
    [~, comments.row] = ismember(comments.node, nodes.id);
    nodes.comment = repmat({'~'}, size(nodes, 1), 1);
    nodes.comment(comments.row) = comments.comment;
    nodes.comment = buildCategories(nodes.comment);
    
    % look up segment IDs
    nodes.coord = nodes.coord + 1;
    nodes.segId = Seg.Global.getSegIds(param, nodes.coord);
    
    % remove nodes on border
    nodes = nodes(logical(nodes.segId), :);
end

function names = buildCategories(names)
    % It's convenient to have multiple trees per category. In order to
    % allow for that, we discard the underscore-separated suffix.
    dropSuffix = @(n) n(1:min([strfind(n, '_') - 1, numel(n)]));
    names = cellfun(dropSuffix, names, 'UniformOutput', false);
    names = categorical(lower(names));
end

function map = buildIdToRowMap(trees)
    maxId = max(trees.id);
    
    % build map
    map = zeros(maxId, 1);
    map(trees.id) = 1:height(trees);
end

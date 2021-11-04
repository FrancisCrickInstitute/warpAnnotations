function skel = buildSkeleton(trees)
    % skel = buildSkeleton(trees)
    %   Builds a skeleton object out of a tree table.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    skel = skeleton();
    
    for curIdx = 1:size(trees, 1)
        skel = addTree(skel, trees(curIdx, :));
    end
end

function skel = addTree(skel, tree)
    nodes = tree.nodes{1};
    edges = tree.edges{1};
    
    % build nodes and edges
    edges = [edges.source, edges.target];
    [~, edges] = ismember(edges, nodes.id);
    nodes = 1 + [nodes.x, nodes.y, nodes.z];
    
    % tree name and color
    name = tree.name{1};
    color = [tree.color, 1];
    
    skel = skel.addTree(name, nodes, edges, color);
end
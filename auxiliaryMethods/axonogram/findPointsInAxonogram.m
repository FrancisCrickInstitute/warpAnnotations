function XY = findPointsInAxonogram(idx_points, TREE, tree, scale)
XY = [];
for i = 1:length(idx_points)
    
    % find first my point in Baum
    start = idx_points(i);
    found = false;
    c = 1;
    while found == false
        idx = find(TREE(c).points == start);
        if ~isempty(idx)
            found = true;
        else
            c = c+1;
        end
    end
    
    nodes = tree.nodes(TREE(c).points(1:idx)',1:3).* repmat(scale, size(tree.nodes(TREE(c).points(1:idx)'),1), 1);
    one = nodes((1:size(nodes,1)-1)',:);
    two = nodes((2:size(nodes,1))',:);
    l = sum(sqrt(sum((one-two).^2,2)))/1000;
    
    XY(end+1,:) = [TREE(c).xy_start(1)+l, TREE(c).xy_start(2)];
    
end
end
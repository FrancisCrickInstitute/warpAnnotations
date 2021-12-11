function plot_children(ID,Subtree, x,y, shift)
global TREE

% plot horizontal
plot([x x+Subtree.length],[y y], 'k', 'LineWidth', 2)
TREE(ID).xy_start = [x y];

% if not leaf:
if ~isempty(Subtree.children)
    
    b = Subtree.width/2;
    ii = Subtree.children;
    d1 = TREE(ii(1)).width/2;
    d2 = TREE(ii(end)).width/2;
    
    plot([x+Subtree.length x+Subtree.length],[y+b-d1 y-b+d2], 'k', 'LineWidth', 2)
    plot_children(TREE(ii(1)).treename, TREE(ii(1)), x+Subtree.length, y+b-d1, shift);
    plot_children(TREE(ii(end)).treename, TREE(ii(end)), x+Subtree.length, y-b+d2, shift);

    delta = d1*2;
    ii(1) = []; ii(end) = [];
    if ~isempty(ii)
        for i = ii
            delta = delta + shift + Baum{i,4}/2;
            plot_children(TREE(ii(1)).treename, TREE(ii(1)), x+Subtree.length, y+b - delta, shift);
        end
    end
    
end


end

function w = children_width(children,shift)
global TREE

if  isempty(children) % number of children 0
    w = 0;
else
    w = 0;
    for i = children
        w = w + children_width(TREE(i).children,shift);
    end
    w = w + shift*(length(children)-1);
end

end
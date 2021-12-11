function TREE = axonogram(tree, comments, startpoint, scale, drawFigure)

if nargin < 5
    drawFigure = 1;
end

%% Preprocessing
%  Find  Endings, Branchpoints

bi_edges = [tree.edges(:,1) tree.edges(:,2); tree.edges(:,2) tree.edges(:,1)];

edges = bi_edges(:,1);
binvec = min(edges):1:max(edges)+1;
h = histc(edges, binvec);
bp = find(h>2); % branchpoints
ep = find(h==1); % endpoints

branchpoints = binvec(bp)';
endpoints = binvec(ep)';
start_idx = find(edges == startpoint);

%% Baum structure: #tree | Kinder | points | breite | length (um) | [x y] plot start
global TREE;
TREE = struct('treename',[],'children',[],'points',{}, 'width', [], 'length', [], 'xy_start', []);
child_idx = start_idx(1);
child_nr = 1;

while ~isempty(child_nr)
    
    points = edges(child_idx(1)); % save first point
    first_p = bi_edges(child_idx(1),2); % get next first point
    while ~ismember(first_p,branchpoints) && ~ismember(first_p,endpoints)
        points(end+1) = first_p;
        idx = find(edges(:,1) == first_p);
        
        % check if already been there
        if ismember(bi_edges(idx(1),2), points)
            idx = idx(2);
        else
            idx = idx(1);
        end
        first_p = bi_edges(idx,2);
    end
    points(end+1) = first_p;
    
    if ismember(first_p,endpoints)
        next_nr = [];
    end
    
    if ismember(first_p,branchpoints)
        next_idx = find(edges == first_p)';
        next_idx = next_idx(find(ismember(bi_edges(next_idx,2),points)==0)');
        
        child_idx = [child_idx next_idx];
        next_nr = child_nr(end)+(1:length(next_idx));
        child_nr = [child_nr next_nr];
    end
    
    TREE(end+1).treename = child_nr(1);
    TREE(end).children = next_nr;
    TREE(end).points = points;
    
    child_idx(1)=[]; child_nr(1)=[];
end

% calculate length of branches
for i = 1:size(TREE,2)
    nodes = tree.nodes(TREE(i).points',1:3).* repmat(scale, size(tree.nodes(TREE(i).points'),1), 1);
    one = nodes((1:size(nodes,1)-1)',:);
    two = nodes((2:size(nodes,1))',:);
    TREE(i).length = sum(sqrt(sum((one-two).^2,2)))/1000;
end

%% calculate width of children
shift = 5;
for ii = 1:size(TREE,2)
    TREE(ii).width = children_width(TREE(ii).children, shift);
end

%% plot children
if drawFigure == 1
    figure
    hold on
    % plotte(1,Baum(1,:), Baum, 0,0, shift)
    plot_children(1,TREE(1), 0,0, shift)
    set(gca,'TickDir','out','Box','off','FontSize',18)
    set(gca,'YTick',[])
    xlabel('path length from soma (µm)')
    title(tree.name(1:7))
end

end



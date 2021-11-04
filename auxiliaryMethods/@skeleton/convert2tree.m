function tree = convert2tree(skel,tree_index)
% transforms one or more skeletons into TREES toolbox trees
% author: Marcel Beining (marcel.beining@gmail.com)
if nargin < 2 || isempty(tree_index)
    tree_index = 1:numel(skel.nodesAsStruct);
end
tree = cell(numel(tree_index),1);
for t = 1:numel(tree_index)
    skel.edges{tree_index} = sortrows(skel.edges{tree_index(t)});
    [mx,ind] = max(cellfun(@numel,skel.getNeighborList(tree_index(t)))); % search for a good root for directed tree, first check if there is a node which has many neighbor nodes (soma with dendrites/axons)
    if mx <= 2 || numel(ind) ~= 1  % if not found, just use first node index
        ind = find(skel.nodes{tree_index(t)}(:,4)==max(skel.nodes{tree_index(t)}(:,4)));  % search for a good root for directed tree, second check if there is a node that has very huge radius (soma)
        if numel(ind) ~= 1
            ind = skel.edges{tree_index(t)}(1,1);
        end
    end
    % if skeleton has no branchpoints, make an end the root
    if isempty(skel.getBranchpoints(t))
        ind = skel.getEndpoints(t);
        ind = ind(1);
    end
    skel = skel.sortNodes(tree_index(t),cat(2,ind,1:ind-1,ind+1:size(skel.nodes{tree_index(t)},1)));
    ind = 1;  % now root is at one
    dAprev = (skel.createAdjacencyMatrix(tree_index(t))); % get symmetric adjacency matrix
    [~, ~, pred] = graphshortestpath(dAprev, ind);  % get predecessor nodes toward chosen root for each node
%     XYZD = skel.nodes{tree_index(t)};
%     XYZD = XYZD([ind;1:numel(skel.nodes{tree_index(t)}
    pred(ind) = [];  % delete root information
    tree{t}.dA = sparse(setdiff(1:length(dAprev),ind),pred,true(1,length(dAprev)-1),length(dAprev),length(dAprev));  % make directed adjacency matrix
    tree{t}.X = cellfun(@(x) str2double(x),{skel.nodesAsStruct{tree_index(t)}.x})' * skel.scale(1);
    tree{t}.Y = cellfun(@(x) str2double(x),{skel.nodesAsStruct{tree_index(t)}.y})' * skel.scale(2);
    tree{t}.Z = cellfun(@(x) str2double(x),{skel.nodesAsStruct{tree_index(t)}.z})' * skel.scale(3);
    tree{t}.D = cellfun(@(x) str2double(x),{skel.nodesAsStruct{tree_index(t)}.radius})' * mean(skel.scale);  % not completely sure, have to check..also radius is of course probably not completely correct as voxel size is not isometric
    tree{t}.comment = {skel.nodesAsStruct{tree_index(t)}.comment}';  % not used in Trees Toolbox but field might be important to import too
    tree{t} = repair_tree(tree{t});  % eliminate trifurcations etc
end
if numel(tree_index(t)) == 1
    tree = tree{1};
end
end
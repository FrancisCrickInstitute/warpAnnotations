function  skel  = setNodes( skel,tree_index, nodes)
%SETNodes Summary of this function goes here
%   from Kevin's skeleton class

    assert(size(nodes, 1) == size(skel.nodes{tree_index}, 1));
    skel.nodes{tree_index}(:, 1 : 3) = nodes;
    skel.nodesNumDataAll{tree_index}(:, 3 : 5) = nodes;
    dimNames = 'xyz';
    for dimIt = 1 : 3
        temp = convertNumbersForNodesAsStruct(nodes(:, 1));
        [skel.nodesAsStruct{tree_index}(:).(dimNames(dimIt))] = temp{:};
    end
end
function y = convertNumbersForNodesAsStruct(numbers)
            y = strtrim(cellstr(num2str(numbers)))';
end

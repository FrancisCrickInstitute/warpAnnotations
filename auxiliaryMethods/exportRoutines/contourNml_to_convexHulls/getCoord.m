% function to retrieve coordinates of all nodes (soma-clicked trees)
function nodesCoord = getCoord(skel)
for i = 1:numTrees(skel)
    nodesCoord(i,:) = skel.nodes{i}(1:3)
end
end
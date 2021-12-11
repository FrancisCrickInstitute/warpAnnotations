function G=showNetwork(obj,tree_index)
    function networkwalker(node,depth, referer)
        done=[done node];
        if length(positions)<depth
            positions{depth}=node;
        else
            positions{depth}=[positions{depth} node];
        end
        for i=find(am(node,:))
            if ~isempty(find(done==i,1))
                disp('circle found');
                continue;
            end
            if i~=referer
                networkwalker(i,depth+1, node);
            end
        end
    end
done=[];
positions=cell(0);
am=createAdjacencyMatrix(obj,tree_index);
networkwalker(1,1,-1);
addtosystempath('C:\Program Files (x86)\Graphviz2.30\bin');
labels= feval(@(x)mat2cell(x,(1:size(x,1))*0+1,size(x,2)),num2str(obj.nodesNumDataAll{tree_index}(:,1)));
G=graphViz4Matlab('-adjMat',am,'-nodeLabels',labels);
for j=1:length(positions)
    for k=1:length(positions{j})
        real_positions(positions{j}(k),:)=[j/(length(positions)+1) k/(length(positions{j})+1)];
    end
end

G.setNodePositions(real_positions)
G.redraw_handle=@()G.setNodePositions(real_positions);
end
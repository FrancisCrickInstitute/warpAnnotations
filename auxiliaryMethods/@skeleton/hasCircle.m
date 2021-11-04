function cf=hasCircle(obj,tree_index)
    function networkwalker(node,depth, referer)
        done=[done node];
        for i=find(am(node,:))
            if i~=referer && ~isempty(find(done==i,1))
                cf=true;
                continue;
            end
            if i~=referer
                networkwalker(i,depth+1, node);
            end
        end
    end
cf=false;
done=[];
am=createAdjacencyMatrix(obj,tree_index);
networkwalker(1,1,-1);
end
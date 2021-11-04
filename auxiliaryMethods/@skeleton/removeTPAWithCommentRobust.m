function skel = removeTPAWithCommentRobust( skel, comment, mode , steps,twoPointAnnotation)
%REMOVETPAWITHCOMMENT Remove three-point annotations with the specified
% comment. Additionally don't delete nodes with degree greate than 2
% INPUT comment: string
%           see skeleton.getNodesWithComment
%       mode: string
%           see skeleton.getNodesWithComment
%       steps: number of steps to walk from the comment node
%       twoPointAnnotation: Boolean if only comment + its child end node
%                           should be deleted (= two point annotation)
% OUTPUT skel: skeleton object
%           Skeleton object with TPAs removed.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% Modified by: Sahil Loomba <sahil.loomba@brain.mpg.de> and Marcel Beining <marcel.beining@brain.mpg.de>
if ~exist('steps','var') || isempty(steps)
    steps = 1;
end
if ~exist('twoPointAnnotation','var') || isempty(twoPointAnnotation)
    twoPointAnnotation = 0;
end

nodes = skel.getNodesWithComment(comment, [], mode);
if ~iscell(nodes)
    nodes = {nodes};
end

nodesDegrees = skel.calculateNodeDegree;

for tr = 1:skel.numTrees()
    toDel = find(skel.reachableNodes(tr, nodes{tr}, steps, 'up_to'));
    if twoPointAnnotation
        toDel = intersect(toDel,cat(1,find(nodesDegrees{tr}==1),nodes{tr}));
    else
        % check is the toDel node has degree 3 then don't delete it
        notToDel = nodesDegrees{tr}(toDel)>=3;
        if any(notToDel)
            toDel(notToDel) = [];
        end
    end
    skel = skel.deleteNodes(tr, toDel); 
    
end

end


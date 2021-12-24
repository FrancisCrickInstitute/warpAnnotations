function [ intersectionBbox ] = intersectBbox( bbox1,bbox2 )
%INTERSECTBBOX Gives you the intersection of two bboxes
MinSide=max([bbox1(:,1),bbox2(:,1)],[],2);

MaxSide=min([bbox1(:,2),bbox2(:,2)],[],2);

intersectionBbox=[MinSide,MaxSide];
assert(all((diff(intersectionBbox,1,2))>=0),'No intersection possible')
end


function [ seg ] = getSegSmall( pCube, idConv )
%GETSEGSMALL Get the segmentation matrix for bbox small.
% INPUT pCube: Parameter struct for a local segmentation cube, e.g.
%       	p.local(1)
%       idConv: (Optional) Boolean specifying whether IDs should be
%           converted to global indices.
%           (Default: false)
% OUTPUT seg: The segmentation matrix of the corresponding cube for
%           bboxSmall.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

m = load(pCube.segFile);
from = pCube.bboxSmall(:,1) - pCube.bboxBig(:,1) + 1;
to = from + pCube.bboxSmall(:,2) - pCube.bboxSmall(:,1);
seg = m.seg(from(1):to(1),from(2):to(2),from(3):to(3));
if exist('idConv','var') && ~isempty(idConv) && idConv
    seg = Seg.Local.localGlobalIDConversion('LocalToGlobal',pCube,seg);
end


end


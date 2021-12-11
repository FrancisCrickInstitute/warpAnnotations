function plotBbox( bbox, col,facealpha,ecol )
% plots a semi transparent bbox
% INPUT
% bbox  3x2 or 2x3 matrix describing start end end points of bbox
% col   string or 1x3 vector to apply a color on the bbox patch. default is
%       red

if ~exist('col','var') || isempty(col)
    col = [1 0 0];
end
if ~exist('ecol','var') || isempty(ecol)
    ecol = [0 0 0];
end
if ~exist('facealpha','var') || isempty(facealpha)
    facealpha = 0.1;
end

if size(bbox,2) == 3 && size(bbox,1) == 2
    bbox = bbox';
elseif length(bbox) == 6
   bbox = [bbox(1:3)',bbox(1:3)'+bbox(4:6)'-1];
end

widths = diff(bbox,1,2)';
offset = bbox(:,1)';
pvec = str2double(num2cell(dec2bin(0:7)));  % create edge points of bbox of size 1
pvec = bsxfun(@plus,bsxfun(@times,pvec,widths),offset); % scale it to the size of the bbox
hold on
for u = 1:2
    patch('Faces',[1 2 4 3 1],'Vertices',pvec,'FaceAlpha',facealpha,'FaceColor',col,'EdgeColor',ecol)
    patch('Faces',[1 2 6 5 1],'Vertices',pvec,'FaceAlpha',facealpha,'FaceColor',col,'EdgeColor',ecol)
    patch('Faces',[1 3 7 5 1],'Vertices',pvec,'FaceAlpha',facealpha,'FaceColor',col,'EdgeColor',ecol)
    pvec = flipud(pvec);
end

end


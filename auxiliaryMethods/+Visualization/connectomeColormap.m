function cmap = connectomeColormap( m )
%CONNECTOMECOLORMAP Return the default connectome colormap.
% The default colormap is currently hsv cropped roughly at half and black
% added as first color.
% INPUT m: (Optional) int
%           Number of different colors.
%           (Default: same length as current figures colormap)
% OUTPUT cmap: [mx3] double
%           Connectome colormap.
%
% NOTE To define this colormap for the current figure use
%      colormap(Visualization.connectomeColormap())
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('m','var') || isempty(m)
    m = size(get(gcf,'colormap'),1);
end
cmap = hsv(2*m - 1);
cmap = cmap(ceil(end/2) + 1:end,:); %crop for hsv to prevent cyclic colors
cmap = [[0, 0, 0]; cmap]; %zeros in black

end


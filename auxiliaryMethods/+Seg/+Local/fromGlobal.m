function [seg, segIds] = fromGlobal(seg)
    % [seg, segIds] = fromGlobal(seg)
    %   Converts a volume with global segmentation IDs into one with local
    %   segment IDs. That is, the segments in the output volume will be
    %   numbered consecutively starting from one.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    segSize = size(seg);
    [segIds, ~, seg] = unique(seg);
    
    if ~segIds(1)
        seg = seg - 1;
        segIds = segIds(2:end);
    end
    
    % shape output
    seg = reshape(seg, segSize);
    segIds = segIds(:);
end
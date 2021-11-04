function skel = setEditPosition(skel, pos)
    % skel = setEditPosition(skel, pos)
    %   Sets the edit position such that the webKNOSSOS view-
    %   port will be focused on the point `pos` upon loading
    %   the NML file.
    %
    % pos
    %   Vector with X, Y, and Z coordinate
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    
    assert(numel(pos) == 3);
    
    if ~iscell(pos)
        % convert numbers to strings
        pos = arrayfun(@num2str, pos, 'UniformOutput', false);
    end
    
    % modify skeleton
    skel.parameters.editPosition = struct( ...
        'x', pos{1}, 'y', pos{2}, 'z', pos{3});
end

function agglos = fromAgglo(agglos, segPos, method, varargin)
    % agglos = fromAgglo(agglos, segPos, method, varargin)
    %   Converts regular agglomerates (i.e., segment equivalence classes)
    %   into super-agglomerates.
    %
    % agglos
    %   Cell array with segment equivalence classes.
    %
    % segPos
    %   Nx3 matrix, where the entries of the i-th row denote the position
    %   of the segment with ID i.
    %
    % method
    %   String. Indicates how agglomerates are converted into
    %   super-agglomerates. Possible values:
    %
    %   * mst: The minimum spanning tree representation of the agglomerates
    %     will be produced.
    %   * subgraph: The sub-graph induced induced by the segment
    %     equivalence class will be returned (not implemented yet).
    %
    %   Default value: `mst`.
    %
    % Written by
    %   Alessandro Motta <alessandro.motta@brain.mpg.de>
    opt = struct;
    opt.voxelSize = [1, 1, 1];
    opt = Util.modifyStruct(opt, varargin{:});
    
    switch method
        case 'mst'
            % Nodes only
            agglos = cellfun( ...
                @(segIds) struct( ...
                    'nodes', horzcat( ...
                        segPos(segIds, :), ...
                        segIds(:)), ...
                    'edges', zeros(0, 2)), ...
                agglos);
            
            % Edges only
            agglos = SuperAgglo.toMST(agglos, opt.voxelSize);
        case 'subgraph'
            error('Not implemented yet')
        otherwise
            error('Invalid method "%s"', method)
    end
end

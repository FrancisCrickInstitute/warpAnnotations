classdef EdgeLookup
    %EDGELOOKUP Edge lookup class.
    % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
    
    properties
        eIdx
        idStartIdx
        exactPos = false;
    end
    
    methods
        function obj = EdgeLookup(edges, exactPos)
            if exist('exactPos', 'var') && ~isempty(exactPos) ...
                    && islogical(exactPos)
                obj.exactPos = exactPos;
            end
            [obj.eIdx, obj.idStartIdx] = ...
                Seg.Global.EdgeLookup.edgesLUT(edges, obj.exactPos);
                
        end
        
        function [idx, l] = edgeIdx(obj, segIds, toCellArray)
            % Returns the edge indices for the specified segment ids.
            % INPUT segIds: [Nx1] int
            %           Array of segment ids to query.
            %       toCellArray: (Optional) logical
            %           Flag indicating the the output is not converted to
            %           a cell array and simply contains the indices for
            %           all segment ids in one numerical array.
            % OUTPUT idx: [Nx1] int or cell
            %           Array of edge indices for all segment ids or cell
            %           array of edge indices for the corresponding segId.
            %        l: [Nx1] int
            %           The number of edge indices for the corresponding
            %           seg id.
            % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

            sidx = [obj.idStartIdx(segIds), obj.idStartIdx(segIds + 1) - 1];
            l = diff(sidx, [], 2) + 1;
            idx = zeros(sum(l), 1);
            count = 1;
            for i = 1:length(l)
                idx(count:count+l(i)-1) = obj.eIdx(sidx(i, 1):sidx(i, 2));
                count = count + l(i);
            end
            
            if nargin > 2 && toCellArray
                idx = mat2cell(idx, l, 1);
            end
        end
    end
    
    methods (Static)
        function [eIdx, idStartIdx] = edgesLUT( edges, exactPos )
        %EDGESLUT Different form of edge lookup not using cell arrays.
        % INPUT edges: [Nx2] int
        %           Edge list.
        %       exactPos: (Optional) logical
        %           Flag indicating to output the exact position of each id
        %           and not just the row index.
        %           (Default: false)
        % OUTPUT eIdx: [Nx1] int
        %           The edge indices sorted by increasing segment ids.
        %        idStartIdx: [Nx1] int
        %           The start index w.r.t. idx for the corresponding
        %           segment id.
        %           I.e. the edge indices for segment k are available via
        %           idx(idStart(k):idStart(k+1)-1))
        % Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

        [segId, eIdx] = sort(edges(:), 'ascend');

        [uSegId, uSegIdStartIdx] = unique(segId);
        idStartIdx = repelem(uSegIdStartIdx, ...
            [uSegId(1); diff(uSegId)]);
        idStartIdx(end+1) = length(eIdx) + 1;

        % only row indices
        if ~exist('exactPos', 'var') || ~exactPos
            [eIdx, ~] = ind2sub(size(edges), eIdx);
        end

        end
    end
    
end


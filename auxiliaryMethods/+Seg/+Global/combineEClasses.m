function [ eClass, old2NewIdx ] = combineEClasses( eClassList, ...
    ignoreSize1Classes )
%COMBINEECLASSES Combine sets of equivalence classes
% INPUT eClassList: [Nx1] cell array of [Mx1] cell array of integer arrays
%           (equivalence classes) or [Nx1] cell array of integer arrays.
%       ignoreSize1Classes: (Optional) logical
%           Flag to ignore equivalence classes that consist of a single
%           element only.
%           (Default: true)
% OUTPUT eClass: Equivalence set generated taking the connected components
%           on the graph with edges between all ids within each equivalence
%           class.
%        old2NewIdx: [Nx1] int or [Nx1] cell of [Mx1] int
%           Mapping from the old equivalence classes to the new ones, i.e.
%           eClassList{i} is now part of old2NewIdx(i).
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

eClassList = eClassList(:);

%create edges list with edges between all ids contained in each equivalence
%class
if iscell(eClassList{1})
    l = cellfun(@length, eClassList);
    toCell = true;
    eClassList = vertcat(eClassList{:});
else
    toCell = false;
end
edges = cellfun(@(x)x([1:length(x)-1;2:length(x)])', ...
    eClassList,'UniformOutput',false);

% add components with one id only
if exist('ignoreSize1Classes', 'var') && ~ignoreSize1Classes
    edges = cat(1, edges, ...
        cell2mat(cellfun(@(x)[x, x], ...
        eClassList(cellfun(@length, eClassList) == 1), 'uni', 0)));
end

% cast to same datatype
edges = cellfun(@uint32, edges, 'UniformOutput', false);

% calculate new equivalence classes
edges = cell2mat(edges);
eClass = Graph.findConnectedComponents(edges, false, true);

% get idx of output eClass for input eClasses
if nargout > 1
    idToEClass = Seg.Global.eClassLookup(eClass, max(edges(:)));
    old2NewIdx = full(idToEClass(cellfun(@(x)x(1), eClassList)));
    if toCell
        old2NewIdx = mat2cell(old2NewIdx, l, 1);
    end
end
end


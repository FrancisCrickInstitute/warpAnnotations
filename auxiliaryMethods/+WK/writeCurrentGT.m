function writeCurrentGT( ground_truth, folder)
components = arrayfun(@(x)double(cell2mat(ground_truth.segIds(ground_truth.eqClass == x)')), ...
    1:max(ground_truth.eqClass), 'uni', 0);
% all other IDs to zero
components = [components, ...
    setdiff(0 : 14E6, cell2mat(ground_truth.segIds'))];

WK.makeWKMapping(components, ['GT_' datestr(clock, 30)], folder);
end

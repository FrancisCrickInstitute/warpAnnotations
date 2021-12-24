function bbox = approximateDatasetBoundingBox(folder)
% Finds an approximate bounding box for a dataset by counting files
% Seems quite suboptimal

if exist(fullfile(folder, 'header.wkw'), 'file')
    [z_lower, z_upper, z_mid] = minMax(fullfile(folder, 'z*'), 1024);
    [y_lower, y_upper, y_mid] = minMax(fullfile(folder, z_mid, 'y*'), 1024);
    [x_lower, x_upper, x_mid] = minMax(fullfile(folder, z_mid, y_mid, 'x*'), 1024);
elseif ~isempty(dir(fullfile(folder, 'x*')))
    [x_lower, x_upper, x_mid] = minMax(fullfile(folder, 'x*'), 128);
    [y_lower, y_upper, y_mid] = minMax(fullfile(folder, x_mid, 'y*'), 128);
    [z_lower, z_upper, z_mid] = minMax(fullfile(folder, x_mid, y_mid, 'z*'), 128);
else
    error('Could not determine dataset format');
end 

bbox = [x_lower, x_upper; y_lower, y_upper; z_lower, z_upper];

end

function [lower, upper, mid] = minMax(searchString, cubeSize)
    files = dir(searchString);
    f = @(x)str2double(regexp(x.name, '\d+', 'match', 'once'));
    [folderNumbers, idx] = sort(arrayfun(f, files));
    lower=folderNumbers(1)*cubeSize+1;
    upper=(folderNumbers(end)+1)*cubeSize;
    mid=files(idx(ceil(length(idx)/2))).name;
end


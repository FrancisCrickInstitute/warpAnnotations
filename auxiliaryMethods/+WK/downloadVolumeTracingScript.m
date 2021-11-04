function [ script ] = downloadVolumeTracingScript( bbox, downloadRaw )
%DOWNLOADVOLUMETRACINGSCRIPT Script to download a volume tracing/raw data
%in a specified bounding box.
% INPUT bbox: [3x2] int
%           The bounding box do download.
%       downloadRaw: (Optional) logical
%           Flag to download raw data instead of seg.
%           (Default: false)
% OUTPUT script: string
%           The script as a string.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('downloadRaw', 'var') || isempty(downloadRaw)
    downloadRaw = false;
end

if ~downloadRaw
    layerName = 'api.data.getVolumeTracingLayerName()';
else
    layerName = '"color"';
end

sBbox = WK.bbox2Str(bbox, true);
script = sprintf(['webknossos.apiReady(3).then(api => ' ...
    'api.data.downloadRawDataCuboid(%s, %s))'], layerName, sBbox);


end


function  segmentMeta( p )
%SEGMENTMETA Calculates and store the segment meta file.
% This is only a wrapper function to have references to all important
% pipeline files in one place.
% INPUT p: struct
%           Segmentation parameter struct.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

buildSegmentMetaData(p); % function in pipeline respository

end


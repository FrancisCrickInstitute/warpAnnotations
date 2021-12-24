function [ class ] = maxReqInt( uint )
%MAXREQINT Determine the largest required unsigned integer class.
% INPUT uint: Array of integers. The maximum value is used to determine the
%           required integer class.
% OUTPUT class: String specifying the class.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

m = max(uint);

if m <= intmax('uint8')
    class = 'uint8';
elseif m <= intmax('uint16')
    class = 'uint16';
elseif m <= intmax('uint32')
    class = 'uint32';
elseif m <= intmax('uint64')
    class = 'uint64';
else
    error('Integer too large to fit in predefined integer class.');
end
    
end


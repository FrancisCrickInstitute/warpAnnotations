function s = modifyStruct( s, varargin )
%MODIFYSTRUCT Modify struct fields by name/value pairs.
% INPUT s: A scalar struct.
%       varargin: An arbitrary number of name/value pairs which will be
%           added to the struct s (similar to the constructor of struct).
%           If a fieldname already exists than its value is overritten.
% OUTPUT s: struct
%           Modified input struct.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>
nArgs = length(varargin);
if floor(nArgs/2) ~= nArgs/2
    error('Optional arguments have to be name/value pairs');
end

for pair = reshape(varargin,2,[])
    name = pair{1};
    s.(name) = pair{2};
end

end


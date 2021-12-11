function raw = readRaw( file, siz, prec )
%READRAW Read from raw file.
% INPUT file: Filepath as string. (If the file is in the current path the
%             filename is enough.)
%       siz: (Optional) The size of the cube as integer vector.
%            (Default: [128, 128, 128])
%       prec: (Optional) Precision of data as string. See also fread.
%             (Default: uint8).
% OUTPUT raw: The content of the raw file.
% Author: Benedikt Staffler <benedikt.staffler@brain.mpg.de>

if ~exist('siz','var') || isempty(siz)
    siz = [128, 128, 128];
end

if ~exist('prec','var') || isempty(prec)
    prec = 'uint8';
end

fin = fopen(file,'r');
if fin == -1
    error('Opening file %s failed.', file);
end
raw = fread(fin,Inf,[prec '=>' prec]);
if numel(raw) == prod(siz)
    raw = reshape(raw, siz);
else
    warning('The data in raw does not fit into the specified shape.\n');
end
fclose(fin);


end


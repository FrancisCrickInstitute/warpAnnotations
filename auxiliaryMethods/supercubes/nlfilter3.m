function val = nlfilter3(data, fun, fS)
%NLFILTER3 3d non-linear filter with a custom filtering function applied to
% sliding neighborhoods.
% INPUT data: 3d numerical array
%           The input data.
%       fun: function handle
%           Function handle that is applied separately to each filtering
%           region.
%       fS: [1x3] int
%           The size of the local filtering regions. Filtering regions are
%           non-overlapping and must tile the complete input cube, i.e.
%           each the size of data must be divisible by fS.
% OUTPUT val: 3d numerical array
%           The output array which has the size equal to the number of
%           non-overlapping filter region tiles.
%
% see also nlfilter matlab function.

tmp = size(data)./fS(:)';
if any(tmp ~= round(tmp))
    error('Size of the input cube must be divisible by fS.');
end

dS = size(data);
ri1=reshape(data,[dS(1) fS(2) dS(2)/fS(2) dS(3)]);
ri1=permute(ri1,[2 1 3 4]);
ri1=reshape(ri1,[fS(1)*fS(2) dS(1)*dS(2)/(fS(1)*fS(2)) fS(3) dS(3)/fS(3)]);
ri1=permute(ri1,[1 3 2 4]);
ri1=reshape(ri1,[fS(1)*fS(2)*fS(3) dS(1)*dS(2)*dS(3)/(fS(1)*fS(2)*fS(3))]);
ri1=fun(ri1);
val=reshape(ri1,[dS(1)/fS(1) dS(2)/fS(2) dS(3)/fS(3)]);

end


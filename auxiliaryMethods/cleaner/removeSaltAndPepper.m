function [ x ] = removeSaltAndPepper( x ,sigma)
%CLEAN Detects Scanner noise and replaces it by 3x3 median, change sigma (defualt 4) to change sensitifity
if(~exist('sigma','var'))
    sigma=4;
end

nD=ndims(x);
sX=size(x);
fehler=arrayfun(@(dim)diff(x,1,dim),(1:nD-1).','UniformOutput',false);
fehler=cellfun(@(fehler,dim)cat(dim,zeros(setOne(sX,dim)),fehler).*cat(dim,fehler,zeros(setOne(sX,dim))),fehler,num2cell((1:nD-1).'),'UniformOutput',false);
fehler=permute(fehler,[2:nD+1 1]);
fehler=cell2mat(fehler);
fehler=abs(prod(fehler,nD+1)).*(0.5-all(fehler<0,nD+1));
[meaN,sigmA]=normfit(fehler(:));
fehler=fehler<meaN-sigmA*sigma;
c=zeros(size(x));
for i=1:prod(setOne(setOne(size(x),1),2))
    c(:,:,i)=medfilt2(x(:,:,i),[3 3]);
end
x(fehler)=c(fehler);
end


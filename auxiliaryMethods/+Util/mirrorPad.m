function [pad_img,mask] = mirrorPad(img,padsize)

%example for mirror padding 13.09.16 by PL
% changed 29.12.16 by MBei

%define padsize in px
if nargin < 2 || isempty(padsize)
    padsize = 2000;
end
switch numel(padsize)
   case 1
	padsize = repmat(padsize/2,2,2);
   case 2
	padsize = [padsize(1)/2,padsize(1)/2;padsize(2)/2,padsize(2)/2];
   case 4
   otherwise
	error('Padsize has %d elements, but only 1, 2 and 4 elements are allowed',numel(padsize))
end

pad_img = zeros(size(img,1)+sum(padsize(1,:)),size(img,2)+sum(padsize(2,:)),'uint8');

pad_img(padsize(1,1)+1:padsize(1,1)+size(img,1),padsize(2,1)+1:padsize(2,1)+size(img,2)) = img;
mask = pad_img ~= 0;

[Y,X] = meshgrid(1:size(pad_img,2),1:size(pad_img,1));   %create coordinate matrices for image

flag = true;
counter = 1;
while flag    % this while loop unfortunately is necessary if padded area is larger than image, hence padding has to be done over and over
   display(sprintf('Iteration %d',counter))
   counter = counter + 1;
   mask2 = pad_img ~= 0;
   [img_dist,ind_dist] = bwdist(mask2,'euclidean');    % get distances and index to next nonzero pixel
   if all(img_dist(~mask2(:))== 1)  % if only single pixels with a value of zero remain, give them the mean value of the image (otherwise it might end in a loop if two such pixels oppose each other)
      pad_img(~mask2(:)) = mean(pad_img(:));
      break
   end
   [XX,YY] = ind2sub(size(pad_img),ind_dist);    % transform indices to next nonzero pixel into coordinates

   newX = X(:)+[XX(:)-X(:)]*2;
   newY = Y(:)+[YY(:)-Y(:)]*2;
   if any(newX < 1 | newX > size(pad_img,1)) || any(newY < 1 | newY > size(pad_img,2)) % || any(pad_img(newX,newY)==0)
%      zeroind = find(pad_img(newX,newY)
      newX(newX < 1 | newX > size(pad_img,1)) = NaN;
      newY(newY < 1 | newY > size(pad_img,2)) = NaN;
   else
      flag = false;
   end
   ind = sub2ind(size(pad_img),newX,newY);  % calculate for each image coordinate the vector that points to the mirror pixel and transform it into matrix indices. the mirror pixel is two times the vector to the next nonzeropixel
   indNaN = ind;   
   indNaN(isnan(indNaN)) = 1;  % little trick because next line does not allow NaN as index
   ind(pad_img(indNaN)==0) = NaN;
   ind(isnan(ind)) = find(isnan(ind));   % replace indices with NaN values with index to itsself. this short form only works because numel(ind) == numel(pad_img)
   pad_img = reshape(pad_img(ind),size(pad_img,1),size(pad_img,2));  % get the values of the image at the indices and reshape into image again
end

end


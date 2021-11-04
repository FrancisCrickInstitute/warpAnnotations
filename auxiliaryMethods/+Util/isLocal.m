function flag = isLocal()
% Minimalistic function to find whether you are on local machine or gaba
%   Output: Boolean that is true if you are local and false if you are on gaba
%   Author: 
%           Sahil Loomba <sahil.loomba@brain.mpg.de>
    root = matlabroot;
    flag = isempty(regexpi(root,'gaba')) & isempty(regexpi(root,'garching'));
end



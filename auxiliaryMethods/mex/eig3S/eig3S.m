% Usage:
%   roots = eig3S(A)
%
% A:
%   [6xN] array of double or single. Each column contains the
%   entries of a real symmetric matrix. The i-th matrix is
%   then given by
%
%   [A(1,i), A(2,i),  A(3,i);
%    A(2,i), A(4,i),  A(5,i);
%    A(3,i), A(5,i),  A(6,i)]
%
% roots:
%   [3xN] array of respective type containing the eigenvalues
%   of the i-th matrix in the i-th column. Eigenvalues are sorted
%   in increasing order.
%
% Author:
%   Benedikt Staffler <benedikt.staffler@brain.mpg.de>
% Modified:
%   Alessandro Motta <alessandro.motta@brain.mpg.de>

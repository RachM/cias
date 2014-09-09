function [ f ] = circleInASquare( x, nc, dim )
% Calculates the objective function for the circle in a square problem.
% Arguments:
%           x: n x (nc x dim) matrix of candidate solutions (n solutions of
%           packing nc circles of dimensionality dim)
%           nc: number of circles in the packing problem
%           dim: dimensionality of the packing problem
% Returns:
%           f: n x 1 vector of objective function values
% 
% Copyright (C) 2014 Rachael Morgan (rachael.morgan8@gmail.com)
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

n = size(x,1);

if nc <= 0
    error('Number of circles must be greater than 0');
end

if dim <= 0
    error('Number of dimensions must be greater than 0');
end

if size(x, 2) ~= nc * dim
    error('Invalid coordinates matrix');
end

% Single point
if nc == 1
    f = zeros(n,1);
    return;
end

f = zeros(n,1);

for i=1:n
    coordinates = reshape(x(i,:), nc, dim);
    f(i) = min(pdist(coordinates)); % Minimum Euclidean distance between solutions
end

end
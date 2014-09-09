% Script to calculate a uniform random sample of the CiaS problem
% Requires:
%   - runGetSamples.m to have been run prior to this.
%       - This will put settings.mat and circle data files in the
%       'data/<dim>D/' directory (where <dim> is the dimensionality)
%   - distance_bounds.mat exists in the 'required_data/<dimD/' directory
%       - Contains the maximum and minimum distance of the search space (normalised 
%         to be within [0, 1].
% Outputs:
%   - circle_<nc>.mat: contains x and f for the problem of packing <nc> circles
%   - settings.mat: all settings used
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

clear all;
clc;

dim = 2; % Pack in 2D space
dirName = ['data/',num2str(dim),'D/'];

nBaseSamples = 1000;
nWalks = 30;
bounds = [0,1]; % Pack circles in the unit square
nCircles = 2:100;

save([dirName, 'settings.mat'], 'dim', 'nBaseSamples', 'bounds', 'nCircles', 'nWalks');

for i=1:length(nCircles)
    dimTrue = nCircles(i) * dim; % Number of circles multiplied by dimensionality    
    nSamplesTrue = nBaseSamples * dimTrue; % Scale samples with dimensionality
    
    x = zeros(nWalks, nSamplesTrue, dimTrue);
    f = zeros(nWalks, nSamplesTrue);
    
    RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', nCircles(i))); % So we can reproduce
    
    for j=1:nWalks
        xTemp = rand(nSamplesTrue, dimTrue) * range(bounds) + min(bounds);
        f(j, :) = circleInASquare(xTemp, nCircles(i), dim);
        x(j, :, :) = xTemp;
    end
    f = -f; % Convert to a minimisation problem
    
    save([dirName, 'circle_',num2str(nCircles(i)),'.mat'], 'x', 'f');
    disp(['Finished sampling circle ',num2str(nCircles(i))]);
end

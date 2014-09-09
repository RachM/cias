% Script to calculate metrics from sample of data
% Requires:
%   - runGetSamples.m to have been run prior to this.
%       - This will put settings.mat and circle data files in the
%       'data/<dim>D/' directory (where <dim> is the dimensionality)
%   - distance_bounds.mat exists in the 'required_data/<dimD/' directory
%       - Contains the maximum and minimum distance of the search space (normalised 
%         to be within [0, 1].
% Outputs:
%   - metrics.mat: contains all metrics as arrays
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

dim = 2;
dirName = ['data/',num2str(dim),'D/'];
nKernel = 1000;
save([dirName,'settings.mat'], 'nKernel', '-append');

load([dirName,'settings']);
distanceBounds = load(['required_data/',num2str(dim),'D/distance_bounds.mat']); % Minimum and maximum distances

% FDC
fdc = zeros(length(nCircles),nWalks);
fdcEst = zeros(length(nCircles),nWalks);

% Dispersion
dispersions = zeros(length(nCircles),nWalks);

% Information Content and related metrics
infoContent = zeros(length(nCircles),nWalks);
infoPartial = zeros(length(nCircles),nWalks);
infoStability = zeros(length(nCircles),nWalks);

% Length scale analysis
maxR = zeros(length(nCircles),nWalks);
minR = zeros(length(nCircles),nWalks);
meanR = zeros(length(nCircles),nWalks);
medianR = zeros(length(nCircles),nWalks);
modeR = zeros(length(nCircles),nWalks);
varR = zeros(length(nCircles),nWalks);
entropyR = zeros(length(nCircles),nWalks);
bandwidth = zeros(length(nCircles),nWalks);
kernelF = zeros(length(nCircles),nWalks,nKernel);
kernelX = zeros(length(nCircles),nWalks,nKernel);
    
for i=1:length(nCircles)
    dimTrue = nCircles(i)*dim;
    nSamplesTrue = nBaseSamples*dimTrue;
    dispersionNormaliser = sqrt(dimTrue);
    distanceMin = distanceBounds.dMin(i);
    distanceMax = distanceBounds.dMax(i);
    
    % Load sample of x and f
    load([dirName,'/circle_',num2str(nCircles(i)),'.mat']);
    
    % Open the optimal packing and obtain global solution
    xG = load(['optimal_packings/csq',num2str(nCircles(i)),'.txt']);
    xG = xG(:, 2:dim+1); % Get data of interest
    xG = reshape(xG, 1, dimTrue) + 0.5; % (reshape and fix offset)
    
    [temp xGEstInd] = min(f, [], 2); % Get indices of estimated global optima
    
    for j=1:nWalks
        % Obtain the global optimum from the given sample
        xGEst = reshape(x(j, xGEstInd(j), :), 1, dimTrue);

        xCurrent = reshape(x(j,:,:), nSamplesTrue, dimTrue);
        fCurrent = reshape(f(j,:), nSamplesTrue, 1);

        % Fitness Distance Correlation
        fdc(i, j) = fitnessDistanceCorrelation(xCurrent, fCurrent, xG);
        fdcEst(i, j) = fitnessDistanceCorrelation(xCurrent, fCurrent, xGEst);

        % Dispersion
        sB = round(0.05 * nSamplesTrue); % Best 5%
        dispersionTemp = dispersion(xCurrent, fCurrent, sB);
        dispersionTemp = dispersionTemp / dispersionNormaliser; % Normalise by diameter of search space
        dispersions(i, j) = (dispersionTemp - distanceMin) / (distanceMax - distanceMin);  % Bound normalisation
        clear sB dispersionTemp;
        
        % Information content etc
        [ic, icp, ics] = informationContent(fCurrent);
        infoContent(i, j) = ic;
        infoPartial(i, j) = icp;
        infoStability(i, j) = ics;
        clear ic icp ics;

        % Length Scale analysis
        rStats = lengthScale(xCurrent, fCurrent, nKernel);
        maxR(i, j) = rStats.max;
        minR(i, j) = rStats.min;
        meanR(i, j) = rStats.mean;
        medianR(i, j) = rStats.median;
        modeR(i, j) = rStats.mode;
        varR(i, j) = rStats.var;
        entropyR(i, j) = rStats.entropy;
        bandwidth(i, j) = rStats.kerenelB;
        kernelF(i, j, :) = rStats.kernelF;
        kernelX(i, j, :) = rStats.kernelX;
        clear rStats;
    end

    save([dirName,'/metrics.mat'], 'fdc', 'fdcEst', ...
        'dispersions', ...
        'infoContent', 'infoPartial', 'infoStability', ...
        'maxR', 'minR', 'meanR', 'medianR', 'varR', 'modeR', ...
        'entropyR', 'bandwidth', 'kernelF', 'kernelX');
    disp(['Finished analysing circle ',num2str(nCircles(i))]);
end
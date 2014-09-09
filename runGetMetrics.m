clear all;
clc;

dim = 2;
dirName = ['data/',num2str(dim),'D/'];
nKernel = 1000;

load([dirName,'settings']);

% FDC
fdc = zeros(length(nCircles),nWalks);
fdcEst = zeros(length(nCircles),nWalks);

% Dispersion
disp = zeros(length(nCircles),nWalks);

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
    nSamplesTrue = nSamples*dimTrue;
    
    % Load sample of x and f
    load([dirName,'/circle_',num2str(nCircles(i)),'.mat']);
    
    % Open the optimal packing and obtain global solution
    xG = load(['optimal_packings/csq',num2str(nCircles(i)),'.txt']);
    xG = x_g(:, 2:dim+1); % Get data of interest
    xG = reshape(xG, 1, dimTrue) + 0.5; % (reshape and fix offset)
    
    [temp xGEstInd] = min(f, [], 2); % Get indices of estimated global optima
    
    for j=1:nWalks
        % Obtain the global optimum from the given sample
        xGEst = reshape(x(j, xGEstInd(j), :), 1, dimTrue);

        xCurrent = reshape(x(j,:,:), nSamplesTrue, dimTrue);
        fCurrent = reshape(f(j,:), nSamplesTrue, 1);
        
%         [a ind] = min(f_temp);
%         x_g_est = x_temp(ind,:);

        % Fitness Distance Correlation
        fdc(i, j) = fitnessDistanceCorrelation(xCurrent, fCurrent, xG);
        fdcEst(i, j) = fitnessDistanceCorrelation(xCurrent, fCurrent, xGEst);

        % Dispersion
        sB = round(0.05 * nSamplesTrue); % Best 5%
        disp(i, j) = dispersion(xCurrent, fCurrent, sB);
        
        % Information content etc
        [ic, icp, ics] = informationContent(fCurrent);
        infoContent(i, j) = ic;
        infoPartial(i, j) = icp;
        infoStability(i, j) = ics;

        % Length Scale analysis
        rStats = lengthScale(xCurrent, fCurrent);
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
    end

    save([dirName,'/metrics.mat'], 'fdc', 'fdcEst', ...
        'disp', ...
        'infoContent', 'infoPartial', 'infoStability', ...
        'maxR', 'minR', 'meanR', 'medianR', 'varR', 'modeR', ...
        'entropyR', 'bandwidth', 'kernelF', 'kernelX');
end
clear all;
clc;

dim = 2;
dirName = ['data/',num2str(dim),'D/'];

nBaseSamples = 1000;
nWalks = 30;
bounds = [0,1];
nCircles = 2:100;

save([dirName, 'settings.mat'], 'dim', 'nBaseSamples', 'bounds', 'nCircles', 'nWalks');

for i=1:length(nCircles)
    dimTrue = nCircles(i) * dim; % Number of circles multiplied by dimensionality    
    nSamplesTrue = nBaseSamples * dimTrue; % Scale samples with dimensionality
    
    x = zeros(nWalks, nSamplesTrue, dimTrue);
    f = zeros(nWalks, nSamplesTrue);
    
    RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', nCircles(i))); % So we can reproduce
    
    for j=1:nWalks
        x(j, :, :) = rand(nSamplesTrue, dimTrue) * range(bounds) + min(bounds);
        f(j, :) = circleInASquare(x(j, :, :), nCircles(i), dim);
    end
    
    save([dirName, 'circle_',num2str(nCircles(i)),'.mat'], 'x', 'f');
    disp(['Finished sampling circle ',num2str(nCircles(i))]);
end

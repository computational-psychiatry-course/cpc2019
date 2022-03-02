%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code to produce figure 5 in submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


% clear all
clear

% add paths
addpath('./SimulationFunctions')
addpath('./AnalysisFunctions')
addpath('./HelperFunctions')
addpath('./FittingFunctions')
addpath('./LikelihoodFunctions')


%% compute the confusion matrix (100 synthetic subjects)

% confusion matrix
CM = zeros(3,3);

% experiment parameters
T   = 1000;         % number of trials
mu  = [0.2 0.8];    % mean reward of bandits

fprintf('\nSimulation and model inversion...\n')
reverseStr = '';

% number of iterations
for count = 1:100
    
    % display progress
    msg = sprintf('Iter: %d/%d', count, 100);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    
    % Model 1: Random responding
    b       = rand;
    [a, r]  = simulate_M1random_v1(T, mu, b);
    [~, ~, BEST] = fit_all_v1(a, r);
    CM(1,:) = CM(1,:) + BEST;
    
    % Model 2: Win-stay-lose-shift
    epsilon = rand;
    [a, r]  = simulate_M2WSLS_v1(T, mu, epsilon);
    [~, ~, BEST] = fit_all_v1(a, r);
    CM(2,:) = CM(2,:) + BEST;
    
    % Model 3: Rescorla Wagner
    alpha  = rand;
    beta   = exprnd(1);
    [a, r] = simulate_M3RescorlaWagner_v1(T, mu, alpha, beta);
    [~, ~, BEST] = fit_all_v1(a, r);
    CM(3,:) = CM(3,:) + BEST;
    
end


%% plot the confusion matrix

figure(1);
imagesc(CM)
caxis([0 100])
colormap('gray')
axis square
ylabel('true model')
xlabel('predicted model')
set(gca,'xtick',1:3)
set(gca,'xticklabel',{'Random','WSLS','RW'})
set(gca,'ytick',1:3)
set(gca,'yticklabel',{'Random','WSLS','RW'})
set(gca, 'fontsize', 16);

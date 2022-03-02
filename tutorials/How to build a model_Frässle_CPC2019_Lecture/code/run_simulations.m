%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code to produce figure 2 in submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


clear

addpath('./SimulationFunctions')
addpath('./AnalysisFunctions')
addpath('./HelperFunctions')


%% set up colors
global AZred AZblue AZcactus AZsky AZriver AZsand AZmesa AZbrick

AZred = [171,5,32]/256;
AZblue = [12,35,75]/256;
AZcactus = [92, 135, 39]/256;
AZsky = [132, 210, 226]/256;
AZriver = [7, 104, 115]/256;
AZsand = [241, 158, 31]/256;
AZmesa = [183, 85, 39]/256;
AZbrick = [74, 48, 39]/256;


%% simulate data from different models

% experiment parameters
T   = 100;         % number of trials
mu  = [0.2 0.8];   % mean reward of bandits

% number of repetitions for simulations
Nrep = 110;

% Model 1: Random responding
for n = 1:Nrep
    b = 0.5;
    [a, r] = simulate_M1random_v1(T, mu, b);
    sim(1).a(:,n) = a;
    sim(1).r(:,n) = r;
end

% Model 2: Win-stay-lose-shift
for n = 1:Nrep
    epsilon = 0.1;
    [a, r] = simulate_M2WSLS_v1(T, mu, epsilon);
    sim(2).a(:,n) = a;
    sim(2).r(:,n) = r;
end

% Model 3: Rescorla Wagner
for n = 1:Nrep
    alpha = 0.1;
    beta = 5;
    [a, r] = simulate_M3RescorlaWagner_v1(T, mu, alpha, beta);
    sim(3).a(:,n) = a;
    sim(3).r(:,n) = r;
end


%% win-stay-lose-shift analysis
for i = 1:length(sim)
    for n = 1:Nrep
        sim(i).wsls(:,n) = analysis_WSLS_v1(sim(i).a(:,n)', sim(i).r(:,n)');
    end
    wsls(:,i) = nanmean(sim(i).wsls,2);
end


%% Plot WSLS behavior for all models
figure(1); clf; hold on;
l = plot([0 1], wsls);
ylim([0 1])
axis square
set(l, 'marker', '.', 'markersize', 50, 'linewidth', 3)
legend({'M1: random' 'M2: WSLS' 'M3: RW'}, 'location', 'southeast')
xlabel('previous reward')
ylabel('probability of staying')
set(gca, 'xtick', [0 1], 'tickdir', 'out', 'fontsize', 18, 'xlim', [-0.1 1.1])

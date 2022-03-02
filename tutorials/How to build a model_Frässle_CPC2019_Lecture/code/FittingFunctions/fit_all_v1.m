function [BIC, iBEST, BEST] = fit_all_v1(a, r)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


% fit all models (1-3) of the model space
[~, ~, BIC(1)] = fit_M1random_v1(a, r);
[~, ~, BIC(2)] = fit_M2WSLS_v1(a, r);
[~, ~, BIC(3)] = fit_M3RescorlaWagner_v1(a, r);

% find the best performing model
[M, iBEST] = min(BIC);
BEST = BIC == M;
BEST = BEST / sum(BEST);

end
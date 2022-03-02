function [Xfit, LL, BIC] = fit_M3RescorlaWagner_v1(a, r)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


% specify the objective function (i.e., likelihood) for model 3
obFunc = @(x) lik_M3RescorlaWagner_v1(a, r, x(1), x(2));

% options for optimization function
options = optimoptions('fmincon','Display','off');

% find minimum of negative log-likelihood (under constraints LB and UB)
X0 = [rand exprnd(1)];
LB = [0 0];
UB = [1 inf];
[Xfit, NegLL] = fmincon(obFunc, X0, [], [], [], [], LB, UB, [], options);

% evaluate the BIC
LL = -NegLL;
BIC = length(X0) * log(length(a)) + 2*NegLL;

end
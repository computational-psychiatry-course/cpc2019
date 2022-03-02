function [a, r] = simulate_M3RescorlaWagner_v1(T, mu, alpha, beta)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


% starting values for expectation
Q = [0.5 0.5];

% iterate over trials
for t = 1:T
    
    % compute choice probabilities
    p = exp(beta*Q) / sum(exp(beta*Q));
    
    % make choice according to choice probababilities
    a(t) = choose(p);
    
    % generate reward based on choice
    r(t) = rand < mu(a(t));
    
    % update values
    delta = r(t) - Q(a(t));
    Q(a(t)) = Q(a(t)) + alpha * delta;

end

end
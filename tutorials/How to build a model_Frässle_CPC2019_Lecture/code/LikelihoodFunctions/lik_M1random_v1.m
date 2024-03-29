function NegLL = lik_M1random_v1(a, r, b)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle
%%%%%
%%%%% note r is not used here but included to fit notation better with other
%%%%% likelihood functions

% number of trials
T = length(a);

% loop over all trial
for t = 1:T
    
    % compute choice probabilities
    p = [b 1-b];
    
    % compute choice probability for actual choice
    choiceProb(t) = p(a(t));
    
end

% compute negative log-likelihood
NegLL = -sum(log(choiceProb));

end
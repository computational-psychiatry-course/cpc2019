function out = analysis_WSLS_v1(a, r)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle


% evaluate the probability of staying given previous outcome
aLast = [nan a(1:end-1)];
stay = aLast == a;
rLast = [nan r(1:end-1)];

winStay = nanmean(stay(rLast == 1));
loseStay = nanmean(stay(rLast == 0));
out = [loseStay winStay];

end
function a = choose(p)
%%%%% Bob Wilson & Anne Collins
%%%%% 2018
%%%%% Code accompanying the submitted paper "Ten simple rules for the
%%%%% computational modeling of behavioral data"
%%%%% 
%%%%% adapted by Stefan Fraessle

% choose an action given propability p
a = max(find([-eps cumsum(p)] < rand));

end

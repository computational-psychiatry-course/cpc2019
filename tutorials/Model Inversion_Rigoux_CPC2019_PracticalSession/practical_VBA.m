function [posterior, out, result] = practical_VBA()

% design
% -------------------------------------------------------------------------
% Here we describe the stimuli of a simple delay discounting task in which
% participants have to choose between an low reward but immediate option (1
% euro today) and a higher reard but delayed option (eg. 4 euros in 15
% days)
%
% Usually this script provides a moderatly good recovery performance
% (estimation error around 10%) and correct but unconclusive model
% selection. You can try to play around with the prior to see if you can 
% improve a bit the performances (Tip: we do not expect large parameters). 
% You could also try to simulate multiple subjects! 
% Or maybe you should conclude that drawing random stimuli is not a smart
% move and a more carefully devised design would provide better recovery
% preformances. Use your intuition, or brute force via design optimisation.

%
% number of trials
N = 500;

% random trial conditions
low_reward = 1;
max_high_reward = 5;
max_delay = 30;

% random trial conditions
value_now = 1 * ones (1, N);
value_delay = randi (5, 1, N);
delay = randi (30, 1, N);

% model inputs (each column is a new trial)
u = [ value_now; 
      value_delay; 
      delay]; 


% model definition
% -------------------------------------------------------------------------
% Here we define our different hypotheses about how delay discounts value.
% We implement two competing models: hyperbolic and exponential
% discounting.

% In the VBA, the evolution (state dynamics) and observation (state to
% observation) mappings are always written in the same canonical form. It
% takes as an input the current state, the parameters (theta for the evolution,
% phi for the observation), the current input, and an optional structure 
% (passed via options.inF or options.inG). This function must return the
% next state (for the evolution) or the data prediction (observation).
% Here, we must predict the probability of accepting the delayed option.

% observation function (hyperbolic)
    function g = g_discount_hyp (~, phi, u, ~)
        % subjective value of the delayed option
        SV_delay = u(2) ./ (1 + phi * u(3));
        % subjective value of the immediate option
        SV_now = u(1);   
        % mapping from the value space to [0 1]
        g = VBA_sigmoid (SV_delay - SV_now);
    end

% observation function (exponential)
    function g = g_discount_exp (~, phi, u, ~)
        SV_delay = u(2) * exp (- phi * u(3));
        SV_now = u(1);   
        g = VBA_sigmoid (SV_delay - SV_now);
    end

% simulation
% -------------------------------------------------------------------------
% In this section we simulate artificial data according to the hyperbolic
% model.

% parameters for the simulation (delay discounting rate)
phi = 0.1;

% observation distribution. By default, the toolbox will assume a gaussian
% distribution. 
options.sources.type = 1; % 0: gaussian, 1: binary, 2: categorical

% By default, the toolbox displays information and graphs to show the progress 
% of the invertion and the final results. You can however speed up the inversion
% by swithcing off those infos.
% Uncomment the following lines to switch off the progression infos
% options.verbose = false; % display text in the command window
% options.DisplayWin = false; % display figures

% simulate data using hyperbolic discounting
fprintf('Simulating data using hyperbolic discounting with k = %3.2f\n',phi); 
y = VBA_simulate (N, [], @g_discount_hyp ,[], phi, u, [], [], options);
% type help VBA_simulate for more details about the arguments

% inversion
% -------------------------------------------------------------------------
% In this section we estimate the parameters (posterior distribution) and
% the evidence for the two competing models

% model dimensions
dim.n_phi = 1;

% If we want, we can change the default prior. Try it out!
% options.priors.muPhi = 0;
% options.priors.SigmaPhi = .3; % uncommenting this line shrinks the
% default prior 

% invert hyperbolic discounting model
[posterior(1), out(1)] = VBA_NLStateSpaceModel (y, u, [], @g_discount_hyp, dim, options);
% invert exponential discounting model
[posterior(2), out(2)] = VBA_NLStateSpaceModel (y, u, [], @g_discount_exp, dim, options);

% Note: if you switched off the display (options.DisplayWin = false), you 
% can still show the final results from the posterior and out structures:
% VBA_ReDisplay(posterior(1), out(1))

% Here, we know the true model and parameters that generated the data. We 
% can therefore compute the parameter estimation error to check the
% performance of our experimental design.
estimation_error = posterior(1).muPhi - phi

% model selection
% -------------------------------------------------------------------------
% perform model selection to compare hyperbolic and exponential dicounting
% hypotheses. Of course, you would need to simulate more subjects and try
% different discount factors to really assess the validity of the design

% Note: it is a bit weird to use random effect model selection with only
% one subject. In that case, one would usually just use the Bayes factor:
%   log_BF_1 = out(1).F - out(2).F
%   prob_m1 = VBA_sigmoid(log_BF_1) % ideally, this should be larger than
%   0.5, as 1 is the true model
% However, for the sake of the exercice, we will here use a random effect
% (group level) analysis.

% Collect the model x subject matrix of (approximate) model evidences
F = [out.F]'; 

% Random effect model selection. 
[p, o] = VBA_groupBMC(F);
% check help VBA_groupBMC for more details about the output. the most
% interesting ones are:
o.Ef % expected model frequency
o.pxp % protected exceedance probability

% display statistics
[~, idxWinner] = max(o.Ef);
fprintf('The best model is the model %d: Ef = %4.3f (pxp = %4.3f)\n',idxWinner, o.Ef(idxWinner), o.pxp(idxWinner));

% display
% -------------------------------------------------------------------------
% It is ALWAYS a good idea to (1) plot your data and (2) plot your model
% predictions in a similar fashion. This is the best way to check how your
% different models make differential predictions about specific data
% patterns, and to which degree your data indeed support the best model.

% loop over conditions
for val = unique(value_delay)
    for d = unique(delay)
        % find corresponding trials
        trial_idx = find(u(2, :) == val & u(3, :) == d);
        if ~ isempty (trial_idx)
            % average response rate
            result.pr(val, d) = mean (y(trial_idx));
            % prediction (no need for average!)
            result.gx1(val, d) = out(1).suffStat.gx(trial_idx(1));
            result.gx2(val, d) = out(2).suffStat.gx(trial_idx(1));
        else
            result.pr(val, d) = nan;
            result.gx1(val, d) = nan;
            result.gx2(val, d) = nan;
        end
    end
end
       
% overlay data and model predictions
VBA_figure();

subplot (1, 2, 1); 
title ('hyperbolic model');
hold on;
plot (result.pr', 'o');
set (gca, 'ColorOrderIndex', 1);
plot (result.gx1');

subplot (1, 2, 2); 
title ('exponential model');
hold on;
plot (result.pr', 'o');
set (gca, 'ColorOrderIndex', 1);
plot (result.gx2');

end

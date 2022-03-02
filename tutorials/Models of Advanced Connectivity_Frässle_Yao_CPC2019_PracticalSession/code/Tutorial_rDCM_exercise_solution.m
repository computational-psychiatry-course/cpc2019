%% Computational Psychiatry Course (CPC) 2019
%
% Tutorial: Advanced models of connectivity
% 
% This script describes the use of the regression dynamic causal modeling 
% (rDCM) toolbox for whole-brain effective connectivity analyses. The 
% script will ask you to perform several simulations, exploring different 
% aspects of the model and offering a better feeling for the behaviour of 
% the model.
% 

% ----------------------------------------------------------------------
% 
% stefanf@biomed.ee.ethz.ch
%
% Author: Stefan Fraessle, TNU, UZH & ETHZ - 2019
% Copyright 2019 by Stefan Fraessle <stefanf@biomed.ee.ethz.ch>
%
% Licensed under GNU General Public License 3.0 or later.
% Some rights reserved. See COPYING, AUTHORS.
% 
% ----------------------------------------------------------------------



%% load dummy large-scale DCM and display the connectivity matrix


% get path of rDCM toolbox
P        = mfilename('fullpath');
rDCM_ind = strfind(P,fullfile('rDCM','code'));

% load the example network architecture
temp = load(fullfile(P(1:rDCM_ind-1),'rDCM','test','DCM_LargeScaleSmith_model1.mat'));
DCM  = temp.DCM;


% display the connectivity structure and the time series
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(DCM.Ep.A)
title('Ground truth: endogenous connectivity','FontSize',20)
axis square
caxis([-1 1])
xlabel('region (from)','FontSize',18)
ylabel('region (to)','FontSize',18)



% -----------------------------------------------------------------------
%   Regression DCM under fixed connectivity
% -----------------------------------------------------------------------

%% specify options for rDCM analysis and generate synthetic data

% specify the options for the synthetic BOLD signal
options.SNR             = 3;
options.y_dt            = 0.5;

% run a simulation (synthetic) analysis
type = 's';

% generate synthetic data (for simulations)
DCM = tapas_rdcm_generate(DCM, options, options.SNR);



%% model estimation (fixed connectivity pattern)

% get time
currentTimer = tic;

% run rDCM analysis with fixed connectivity (performs model inversion)
[output, options] = tapas_rdcm_estimate(DCM, type, options, 1);

% output elapsed time
toc(currentTimer)

% plotting options
plot_regions = [1 12];
plot_mode    = 2; 

% visualize the results
tapas_rdcm_visualize(output, DCM, options, plot_regions, plot_mode)

% output a summary of the results
fprintf('\nSummary (rDCM - fixed)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model parameter recovery: \n')
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output.statistics.mse))

% evaluate sensitivity and specificity
[sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output,DCM);

% output sensitivity and specificity
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)



%% vary signal-to-noise ratio of synthetic data

% clear options file
clear options

% asign new DCM
DCM2 = temp.DCM;

% specify the options; use an SNR = 1 for the synthetic BOLD signal
options.SNR     = 1;
options.y_dt	= 0.5;

% generate synthetic data (for simulations)
DCM2 = tapas_rdcm_generate(DCM2, options, options.SNR);
    
% run rDCM analysis
[output2, options] = tapas_rdcm_estimate(DCM2, type, options, 1);

% visualize the results
tapas_rdcm_visualize(output2, DCM2, options, plot_regions, plot_mode)

% output a summary of the results
fprintf('\nSummary (rDCM - fixed - SNR = 1)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model parameter recovery: \n')
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output2.statistics.mse))



%% check influence of "wrong" conenctions (incorrected model)

% add wrong connections
DCM3              = DCM;
noise_connections = rand(size(DCM3.a));
DCM3.a            = DCM3.a + noise_connections > 0.97;

% run rDCM analysis
[output3, options] = tapas_rdcm_estimate(DCM3, type, options, 1);

% visualize the results
tapas_rdcm_visualize(output3, DCM3, options, plot_regions, plot_mode)


% plot the correlation
estimated_params = output3.Ep.A(:);
true_params      = DCM3.Tp.A(:);

vector           = estimated_params ~= 0;
estimated_params = estimated_params(vector==1);
true_params      = true_params(vector==1);

figure, 
plot(true_params,estimated_params,'ro')
hold on
plot([-1 1],[-1 1],'k:')
xlim([-1 1])
ylim([-1 1])
axis square
xlabel('true parameters')
ylabel('estimated parameters')
title('Parameter Recovery under Wrong Model')
box off



% -----------------------------------------------------------------------
%   Regression DCM under sparsity constraints
% -----------------------------------------------------------------------

%% set options for sparse rDCM analysis

% clear the output files and DCM files
clear output output2 output3 options DCM DCM2 DCM3

% set options for the sparse rDCM analysis
options.SNR             = 3;
options.y_dt            = 0.5;
options.p0_all          = 0.15;  % single p0 value (for computational efficiency)
options.iter            = 100;
options.filter_str      = 5;
options.restrictInputs  = 1;



%% model estimation (sparsity constraints)

% asign DCM
DCM = temp.DCM;

% generate synthetic data (for simulations)
DCM = tapas_rdcm_generate(DCM, options, options.SNR);

% run rDCM analysis with sparsity constraints (performs model inversion)
[output, options] = tapas_rdcm_estimate(DCM, type, options, 2);

% visualize the results
tapas_rdcm_visualize(output, DCM, options, plot_regions, plot_mode)

% evaluate sensitivity and specificity
[sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output,DCM);

% output a summary of the results
fprintf('\nSummary (rDCM - sparsity)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture and parameter recovery: \n')
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output.statistics.mse))



%% allow driving inputs to be pruned

% change options to allow for driving inputs to be pruned as well
options.restrictInputs  = 0;
    
% run rDCM analysis with sparsity constraints (performs model inversion)
[output2, options] = tapas_rdcm_estimate(DCM, type, options, 2);

% visualize results and compute sensitivity and specificity
tapas_rdcm_visualize(output2, DCM, options, plot_regions, plot_mode)

% evaluate sensitivity and specificity
[sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output2,DCM);

% output a summary of the results
fprintf('\nSummary (rDCM - sparsity - All inputs)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture and parameter recovery: \n')
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output2.statistics.mse))



%% alter prior assumptions on sparsity of the network

% change options to fix driving inputs again
options.restrictInputs  = 1;

% set the p0 values
p0_test = [0 1];

% results cell
output_all = cell(2,1);

% reduce number of permutations (for computational efficiency)
options.iter = 50;

% run rDCM analysis with sparsity constraints - p0 = 0
options.p0_all          = p0_test(1);
[output_p1, options_p1] = tapas_rdcm_estimate(DCM, type, options, 2);

% run rDCM analysis with sparsity constraints - p0 = 1
options.p0_all          = p0_test(2);
[output_p2, options_p2]	= tapas_rdcm_estimate(DCM, type, options, 2);

% visualize the results
tapas_rdcm_visualize(output_p1, DCM, options_p1, plot_regions, plot_mode)
tapas_rdcm_visualize(output_p2, DCM, options_p2, plot_regions, plot_mode)


% output a summary of the results
fprintf('\nSummary (rDCM - sparsity)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture recovery: \n')


% output sensitivits and specificity
for int = 1:length(p0_test)
    switch int
        case 1
            [sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output_p1,DCM);
        case 2
            [sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output_p2,DCM);
    end
    fprintf('p0 = %d || Sensitivity: %.3G - Specificity: %.3G\n',p0_test(int),sensitivity,specificity)
end

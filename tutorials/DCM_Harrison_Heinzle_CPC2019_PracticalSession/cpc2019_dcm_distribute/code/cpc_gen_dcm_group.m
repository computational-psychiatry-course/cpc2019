clear all

%%

addpath('spm12/')
spm fmri

%%

load('DCM_prespec-1.mat')

%% Simulate a group of DCMs

GCM = {};
SNR = 1.0;
display = false;
n_subj = 10;  % Per group
DCMbase = DCM;
% First group follows example subject, but with increased motor activity
DCMbase.Ep.B(1,3,4) = DCMbase.Ep.B(1,3,4) + 0.2;
DCMbase.Ep.B(2,4,3) = DCMbase.Ep.B(2,4,3) + 0.2;
for n_subj = 1:10
    DCM = DCMbase;
     params = spm_vec(DCM.Ep);
    DCM.Ep = spm_unvec( ...
        params + 0.2 * abs(params) .* randn(size(params)), ...
        DCM.Ep);
    [Y,x,dcm] = spm_dcm_generate(DCM, SNR, display);
    GCM{end+1,1} = dcm;
end

% Second group has tweaked parameters
DCMbase.Ep.A(1,1) = DCMbase.Ep.A(1,1) - 0.5;
DCMbase.Ep.A(2,2) = DCMbase.Ep.A(2,2) - 0.5;
DCMbase.Ep.A(1,2) = DCMbase.Ep.A(1,2) - 0.1;
DCMbase.Ep.A(2,1) = DCMbase.Ep.A(2,1) - 0.1;
DCMbase.Ep.B(1,3,4) = DCMbase.Ep.B(1,3,4) + 0.1;
DCMbase.Ep.B(2,3,3) = DCMbase.Ep.B(2,3,3) + 0.1;
for n_subj = 1:10
    DCM = DCMbase;
     params = spm_vec(DCM.Ep);
    DCM.Ep = spm_unvec( ...
        params + 0.2 * abs(params) .* randn(size(params)), ...
        DCM.Ep);
    [Y,x,dcm] = spm_dcm_generate(DCM, SNR, display);
    GCM{end+1,1} = dcm;
end

save('GCM_prespec-1_sim.mat', 'GCM')

%% Estimate!

matlabbatch = {};

estimate = struct();
estimate.dcms.gcmmat = {'GCM_prespec-1_sim.mat'};
estimate.output.single.dir = {''};
estimate.output.single.name = 'prespec-1_est';
estimate.est_type = 1;
estimate.fmri.analysis = 'time';

matlabbatch{1}.spm.dcm.estimate = estimate;

spm_jobman('run', matlabbatch);

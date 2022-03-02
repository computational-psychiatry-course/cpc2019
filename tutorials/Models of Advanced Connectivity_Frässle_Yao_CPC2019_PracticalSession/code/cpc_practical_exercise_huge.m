%% CPC 2019 practical session - Exercise HUGE
% 
% 
%% init
rng(8032,'twister')

% define group sizes
sizes = [20 20];
% define signal-to-noise ratio
snr = 1;


%% DCM network structure
% set up the DCM network structure
dcm.n = 2;
% TODO: add dcm.a and dcm.c
dcm.a = ...
dcm.c = ...
dcm.b = false(dcm.n, dcm.n, dcm.n);
dcm.d = false(dcm.n, dcm.n,0);


%% experimental stimuli
dcm.U.dt = 2/16;
tmp = tapas_huge_boxcar(dcm.U.dt, [10 5], [8 16], 1./[2 4], [12 8; 20 0]);
dcm.U.u = cell2mat(tmp);
dcm.Y.dt = 16*dcm.U.dt;
dcm.TE = .04;

%% define group-level DCM connectivity
% cluster 1
% set connection strength for first group
% TODO: add dcm.Ep.A and dcm.Ep.C
dcm.Ep.A = ...
dcm.Ep.C = ...
dcm.Ep.B = double(dcm.b);
dcm.Ep.D = double(dcm.d);
dcm.Ep.transit = zeros(dcm.n, 1);
dcm.Ep.decay = zeros(dcm.n, 1);
dcm.Ep.epsilon = 0;
% covariance
tmp = [dcm.a(:);dcm.b(:);dcm.c(:);dcm.d(:)];
dcm.Cp = diag([double(tmp).*.01; ones(2*dcm.n+1, 1)*exp(-6)]);
clusters{1} = dcm;

% cluster 2
% set connection strength for second group
% TODO: add dcm.Ep.A and dcm.Ep.C
dcm.Ep.A = ...
dcm.Ep.C = ...
dcm.Ep.B = double(dcm.b);
dcm.Ep.D = double(dcm.d);
dcm.Ep.transit = zeros(dcm.n, 1);
dcm.Ep.decay = zeros(dcm.n, 1);
dcm.Ep.epsilon = 0;
% covariance
tmp = [dcm.a(:);dcm.b(:);dcm.c(:);dcm.d(:)];
dcm.Cp = diag([double(tmp).*.01; ones(2*dcm.n+1, 1)*exp(-6)]);
clusters{2} = dcm;


%% generate synthetic data
% TODO: create tapas_Huge object
obj = ...
    
% TODO: generate synthetic data
obj = ...

%% plot sample data
n1 = 5;
figure;
subplot(2,1,1);
plot(obj.inputs(n1).u)
title(['Subject ' num2str(n1)])
ylabel('stimuli')
subplot(2,1,2);
plot(obj.data(n1).bold);
ylabel('BOLD')

drawnow


%% export data to SPM's DCM format
% TODO: export generated BOLD time series to SPM's DCM format
[ dcms ] = ...

% fields in the DCM format of SPM
fieldnames(dcms{1})


%% import data from SPM's DCM format to new HUGE object
% TODO: create new object and import data from SPM's DCM format
obj = ...


%% invert HUGE model and plot result
% TODO: for K = 1
obj1 = ...

% TODO: for K = 2
obj2 = ...

% TODO: for K = 3
obj3 = ...

% plot result
nfe = [obj1.posterior.nfe, obj2.posterior.nfe, obj3.posterior.nfe,];
figure;
bar(nfe-min(nfe))

plot(obj2)








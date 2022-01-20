%%% This code is to correct small sample bias from VAR %%%
%%%         Functions are from Ken West                %%%
clear
clc 
%% Import data after STATA VAR
% load data in
B  = importdata('B_CHF.txt');      % Estimates from VAR
SIGMA  = importdata('V_CHF.txt');  % VCV from VAR
T = importdata('T_CHF.txt');       % number of obs. in VAR

%% Prepare for bias correction
% prepare the argument for the function
n = 3; % number of variables
m = 3; % number of lags
r = n*m;
nZtwid = r;
phitwid = B;  % VAR estimate
OMEGA= zeros(r,r);
for i = 1:n
    for j = 1:m
        OMEGA(i,j) = SIGMA(i,j);
    end
end 
omegaUtwid = OMEGA; 
nk = r;
PX = eye(r);

%% Bias estimation
Bias = zeros(r,r);
for i = 1:n
    EetaZtwid0 = OMEGA(:,i)';
    vbias = proc_vb_ma0(nZtwid,phitwid,omegaUtwid,nk,PX,EetaZtwid0);
    Bias(i,:) = vbias';
end
Bias = Bias./T;

%% Bias-corrected estimate
B_new = B - Bias;

E = table(B_new);
writetable(E,'B_new_CHF.txt','Delimiter','\t','WriteRowNames',false);

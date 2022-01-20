%%% This code is to correct small sample bias from VAR %%%
%%%         Functions are from Ken West                %%%
clear
clc 
%% Import data after STATA VAR
% load data in
B  = importdata('B_CAD.txt');      % Estimates from VAR
SIGMA  = importdata('V_CAD.txt');  % VCV from VAR
T = importdata('T_CAD.txt');       % number of obs. in VAR

% B  = importdata('B_CHF.txt');      % Estimates from VAR
% SIGMA  = importdata('V_CHF.txt');  % VCV from VAR
% T = importdata('T_CHF.txt');       % number of obs. in VAR
% 
% B  = importdata('B_DEM.txt');      % Estimates from VAR
% SIGMA  = importdata('V_DEM.txt');  % VCV from VAR
% T = importdata('T_DEM.txt');       % number of obs. in VAR
% 
% B  = importdata('B_FRF.txt');      % Estimates from VAR
% SIGMA  = importdata('V_FRF.txt');  % VCV from VAR
% T = importdata('T_FRF.txt');       % number of obs. in VAR
% 
% B  = importdata('B_GBP.txt');      % Estimates from VAR
% SIGMA  = importdata('V_GBP.txt');  % VCV from VAR
% T = importdata('T_GBP.txt');       % number of obs. in VAR
% 
% B  = importdata('B_ITL.txt');      % Estimates from VAR
% SIGMA  = importdata('V_ITL.txt');  % VCV from VAR
% T = importdata('T_ITL.txt');       % number of obs. in VAR
% 
% B  = importdata('B_JPY.txt');      % Estimates from VAR
% SIGMA  = importdata('V_JPY.txt');  % VCV from VAR
% T = importdata('T_JPY.txt');       % number of obs. in VAR
% 
% B  = importdata('B_NOK.txt');      % Estimates from VAR
% SIGMA  = importdata('V_NOK.txt');  % VCV from VAR
% T = importdata('T_NOK.txt');       % number of obs. in VAR
% 
% B  = importdata('B_SEK.txt');      % Estimates from VAR
% SIGMA  = importdata('V_SEK.txt');  % VCV from VAR
% T = importdata('T_SEK.txt');       % number of obs. in VAR

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
writetable(E,'B_new_CAD.txt','Delimiter','\t','WriteRowNames',false);

% writetable(E,'B_new_CHF.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_DEM.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_FRF.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_GBP.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_ITL.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_JPY.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_NOK.txt','Delimiter','\t','WriteRowNames',false);
% 
% writetable(E,'B_new_SEK.txt','Delimiter','\t','WriteRowNames',false);

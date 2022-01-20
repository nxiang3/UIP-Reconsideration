% function for VAR using OLS to companion form

function [A,SIGMA,U,V] = olsvarc(y,p)
    [t,q] = size(y); %t denotes the number of observation on each variable, where there are q total variables
    y=y';
    Y = y(:,p:t);
    for i =1:p-1
        Y = [Y; y(:,p-i:t-i)]; % This forms the companion matrix
    end;

    X = [ones(1,t-p); Y(:,1:t-p)];
    Y=Y(:,2:t-p+1);
    A = (Y*X')/(X*X');
    U = Y-A*X; %The first two rows of U will be the reduced form residuals
    SIGMA = U*U'/(t-p-p*q-1); % The upper left hand block gives the variance-covariance matrix
    V=A(:,1); %This gives the intercept terms
    A=A(:,2:q*p+1);  % This gives the slope coefficients
end

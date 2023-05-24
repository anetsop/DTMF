function [hd,n]=ideal_bandpass(wc1,wc2,N)
% IDEAL_BANDPASS: takes as input cutoff
% frequencies wc1 and wc2, with wc1<wc2 and builds
% the first N terms of a linear phase ideal bandpass
% filter and returns its impulse response hd along
% with the vector of samples

a = (N-1)/2; % adds linear phase to the filter
m = [0:1:(N-1)]; % vector of samples
n = m-a+eps; % modified vector to avoid the problem when m = 0
hd = (sin(wc2*n)-sin(wc1*n))./(pi*n); % formula of ideal bandpass filter
end
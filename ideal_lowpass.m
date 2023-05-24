function [hd,n]=ideal_lowpass(wc,N)
% IDEAL_LOWPASS: takes as input cutoff
% frequency wc and builds the first N terms
% of a linear phase ideal lowpass filter
% and returns its impulse response hd along
% with the vector of samples

a = (N-1)/2; % adds linear phase to the filter
m = [0:1:(N-1)]; % vector of samples
n = m-a+eps; % modified vector to avoid the problem when m = 0
hd = sin(wc*n)./(pi*n); % formula of ideal lowpass filter
end
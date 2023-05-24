function [hd,n]=ideal_highpass(wc,N)
% IDEAL_HIGHPASS: takes as input cutoff
% frequency wc and builds the first N terms
% of a linear phase ideal highpass filter
% and returns its impulse response hd along
% with the vector of samples

a = (N-1)/2; % adds linear phase to the filter
m = [0:1:(N-1)]; % vector of samples
n = m-a+eps; % modified vector to avoid the problem when m = 0
hd = sinc(n)-sin(wc*n)./(pi*n); % formula of ideal high pass filter
end
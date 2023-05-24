function [y,fsampling] = filter_number(x)
%FILTER_NUMBER: takes input DTMF signal x,
% removes the signals which represent
% digits 1,2 and 3 from it and replaces
% them with signals of the same length
% but with zero values. It stores the new 
% signal with the removed digits in the returned
% value y.

sz = size(x); % see if x is a column vector
if(sz(2) == 1)
    x = x'; % and transform it into a row vector
end

fsampling = 8000; %sampling frequency

wc = pi*733/(fsampling/2); % cutoff frequency
coeff = 758; % number of filter coefficients
hd = ideal_highpass(wc,coeff); % build ideal highpass filter
wHanning = (hanning(coeff))'; % build hanning window
h = hd.*wHanning; % apply window to ideal filter

nDigit = 0:1/fsampling:(0.5-1/fsampling); %duration of one tone
nZero = 0:1/fsampling:(0.1-1/fsampling); %duration of space between tones
lenDigit = length(nDigit); % number of samples of one tone
lenZero = length(nZero); % number of samples of space between tones

lenSignal = length(x); % number of samples of signal x
i=1; % iteration counter
xZeroSignal = zeros(1,lenDigit); % signal to replace signals of digits 1,2 and 3
xZero = zeros(1,lenZero); % %space between tones
N = 2^nextpow2(lenDigit); % number of points for fft transforms
y=[];

while i < lenSignal
    xDigit = x(i:i+lenDigit-1); % take the next digit of the signal
    % adjust counter to point to the digit after that
    i = i + lenZero + lenDigit;
    
    xFilteredDigit = filter(h,1,xDigit); % filter the digit
    
    XwDigit = fft(xDigit,N); %find fft of original digit
    XwFilteredDigit = fft(xFilteredDigit,N); % find fft of its filtered form
    
    % detect if the digit was 1,2 or 3 by comparing the
    % frequency response amplitudes of the filtered and
    % unfiltered versions
    tol = mse(abs(XwDigit),abs(XwFilteredDigit))/length(XwDigit);
    
    % tol < 0.2 means that the digit was not a 1,2 or 3
    if tol < 0.2
        y = [y xDigit]; % so we place the original signal in the output
    else
        y = [y xZeroSignal]; % otherwise we place a signal with zero values
    end
    if i < lenSignal % and we add a space if there are digits left
        y = [y xZero];
    end
end


N = 2^nextpow2(length(y)); % number of points for fft transforms
Yw = fft(y,N); % fft of output signal
Xw = fft(x,N); % fft of input signal

% take half the length of fft to avoid symmetrical peaks
len1=round(length(Yw)/2);
newYw=Yw(1:len1);
newXw=Xw(1:len1);

% compute the frequencies for the plots of Xw and Yw
k=0:(len1-1); % adjust vector to start counting from zero
w=k*(2*pi/length(Yw)); % compute digital cyclic frequencies
W=w*fsampling; % revert to the analog cyclic frequencies
f=W/(2*pi); % find the analog frequencies

% create figure and adjust its width and height
fig = figure(1);
fig.Position = [500 300 700 500];
movegui(fig,'center');

% plot the amplitude of the frequency response of the input(x)
subplot(211);
plot(f,abs(newXw));
% adjust the tickmarks of the x-axis
xtickangle(90);
xticks([697 770 852 941 1209 1336 1477]);
ax=gca;
ax.FontSize = 7;
xlabel('Frequency(Hz)','FontSize',12);
ylabel('|X(\omega)|','FontSize',12);
title('Amplitude spectrum of input signal x[n]','FontSize',12);

subplot(212);
plot(f,abs(newYw));
% adjust the tickmarks of the x-axis
xtickangle(90);
xticks([697 770 852 941 1209 1336 1477]);
ax=gca;
ax.FontSize = 7;
xlabel('Frequency(Hz)','FontSize',12);
ylabel('|Y(\omega)|','FontSize',12);
title('Amplitude spectrum of output signal y[n]','FontSize',12);

end
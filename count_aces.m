function countAces = count_aces(x)
% COUNT_ACES: takes input DTMF signal x,
% filters it in order to maintain only the
% digit 1 and returns the number of digit 1 that
% are represented in the signal

sz = size(x); % see if x is a column vector
if(sz(2) == 1)
    x = x'; % and transform it into a row vector
end

fsampling = 8000; %sampling frequency

wc1=pi*733/(fsampling/2); % cutoff frequency of lowpass filter
wc2 = pi*1146/(fsampling/2); % first cutoff frequency of bandpass filter 
wc3 = pi*1270/(fsampling/2); % second cutoff frequency of bandpass filter

coeff = 758; % number of filters coefficients
[hd1,n] = ideal_lowpass(wc1,coeff); % build ideal lowpass filter
hd2 = ideal_bandpass(wc2,wc3,coeff); % build ideal bandpass filter
% form the equivalent of a paraller connection of hd1 and hd2
hd = hd1 + hd2;
wHanning = (hanning(coeff))'; % build hanning window
h = hd.*wHanning; % apply window to ideal filter

nDigit = 0:1/fsampling:(0.5-1/fsampling); %duration of one tone
nZero = 0:1/fsampling:(0.1-1/fsampling); %duration of space between tones
lenDigit = length(nDigit); % number of samples of one tone
lenZero = length(nZero); % number of samples of space between tones

lenSignal = length(x); % number of samples of signal x
i=1; % iteration counter
countAces = 0; % counter for number of aces
N = 2^nextpow2(lenDigit); % number of points for fft transforms

while i < lenSignal
    xDigit = x(i:i+lenDigit-1); % take the next digit of the signal
    % adjust counter to point to the digit after that
    i = i + lenZero + lenDigit;
    
    xFilteredDigit = filter(h,1,xDigit); % filter the digit
    
    XwDigit = fft(xDigit,N); %find fft of original digit
    XwFilteredDigit = fft(xFilteredDigit,N); % find fft of its filtered form
    
    % detect if the digit was 1 by comparing the
    % frequency response amplitudes of the filtered and
    % unfiltered versions
    tol = mse(abs(XwDigit),abs(XwFilteredDigit))/length(XwDigit);
    
    % tol < 0.2 means that the digit was a 1
    if tol < 0.2
        countAces = countAces + 1; % and update our counter
    end
end

N = 2^nextpow2(length(h)); % number of points for fft transforms
Hw = fft(h,N); % fft of filter's impulse response

% take half the length of fft to avoid symmetrical peaks
len1=round(length(Hw)/2);
newHw=Hw(1:len1);

% compute the frequencies for the plots of Xw and Yw
k=0:(len1-1); % adjust vector to start counting from zero
w=k*(2*pi/length(Hw)); % compute digital cyclic frequencies
W=w*fsampling; % revert to the analog cyclic frequencies
f=W/(2*pi); % find the analog frequencies
% create figure and adjust its width and height
fig = figure(1);
fig.Position = [500 300 700 500];
movegui(fig,'center');
plot(f,abs(newHw));
xtickangle(90);
xticks([697 770 941 1209 1336]);
ax=gca;
ax.FontSize = 7;
xlabel('Frequency(Hz)','FontSize',12);
ylabel('|H(\omega)|','FontSize',12);
title('Magnitude response of filter h[n]','FontSize',12);

end


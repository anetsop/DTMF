function secret_number = decode_DTMF(x)
% DECODE_DTMF: takes a DTMF signal(x)
% and returns the corresponding number

sz = size(x); % see if x is a column vector
if(sz(2) == 1)
    x = x'; % and transform it into a row vector
end

fsampling = 8000; %sampling frequency

wc1=pi*985/(fsampling/2); % cutoff frequency of lowpass filter
wc2 = pi*1146/(fsampling/2); % cutoff frequency of highpass filter

coeff = 758; % number of filter coefficients
hd1 = ideal_lowpass(wc1,coeff); % build ideal lowpass filter
hd2 = ideal_highpass(wc2,coeff); % build ideal highpass filter
wHanning = (hanning(coeff))'; % build hanning window
h1 = hd1.*wHanning; % apply window to ideal lowpass filter
h2 = hd2.*wHanning; % apply window to ideal highpass filter

nDigit = 0:1/fsampling:(0.5-1/fsampling); %duration of one tone
nZero = 0:1/fsampling:(0.1-1/fsampling); %duration of space between tones
lenDigit = length(nDigit); % number of samples of one tone
lenZero = length(nZero); % number of samples of space between tones

% mapping each digit to a signal with two frequences based on
% mapfreq = [0   1209 1336 1477  1633; 
%            697    1    2    3   'A';
%            770    4    5    6   'B';
%            852    7    8    9   'C';
%            941  '*'    0  '#'   'D']

% list of ceilings for low frequencies
freqCeilingListLow = [733 811 896 985];
% list of ceilings for high frequencies
freqCeilingListHigh = [1272 1406 1555 1711];

% array of possible digits
digits = ['1' '2' '3' 'A'; 
           '4' '5' '6' 'B'; 
           '7' '8' '9' 'C'; 
           '*' '0' '#' 'D'];
       
lenSignal = length(x); % number of samples of signal x
i=1; % iteration counter
N = 2^nextpow2(lenDigit); % number of points for fft transforms
secret_number = ''; % decoded number

while i < lenSignal
    xDigit = x(i:i+lenDigit-1); % take the next digit of the signal
    % adjust counter to point to the digit after that
    i = i + lenZero + lenDigit;
    
    % filter the digit to keep only its low frequency
    xDigitLow = filter(h1,1,xDigit);
    % filter the digit to keep only its high frequency
    xDigitHigh = filter(h2,1,xDigit);
    
    % find fft of the digit's filtered forms
    XwDigitLow = fft(xDigitLow,N);
    XwDigitHigh = fft(xDigitHigh,N);
    
    %take half the length of the fft to avoid symetrical peaks
    halfLength = round(length(XwDigitLow)/2);
    XwDigitLowHalf = XwDigitLow(1:halfLength);
    XwDigitHighHalf = XwDigitHigh(1:halfLength);
    
    %find the maximum amplitude of the filtered forms
    lowFreqMaxAmplitude = max(abs(XwDigitLowHalf));
    highFreqMaxAmplitude = max(abs(XwDigitHighHalf));
    
    % find the index of the maximum amplitude
    lowFreqIndex = find(lowFreqMaxAmplitude==abs(XwDigitLowHalf));
    highFreqIndex = find(highFreqMaxAmplitude==abs(XwDigitHighHalf));
    
    % find the corresponding frequency based on the index
    lowFreq = (lowFreqIndex - 1)*fsampling/length(XwDigitLow);
    highFreq = (highFreqIndex - 1)*fsampling/length(XwDigitHigh);
    
    % get the digit's row in the digits array
    % from the digit's lowfrequency
    [r,digitRow] = find(freqCeilingListLow > lowFreq,1);
    [r,digitColumn] = find(freqCeilingListHigh > highFreq,1);
    
    % map frequencies to corresponding digit
    digit = digits(digitRow,digitColumn);
    secret_number = strcat(secret_number,digit);
end

N = 2^nextpow2(length(h1)); % number of points for fft transforms
Hw1 = fft(h1,N); % fft of lowpass filter's impulse response
Hw2 = fft(h2,N); % fft of highpass filter's impulse response

% take half the length of fft to avoid symmetrical peaks
len1=round(length(Hw1)/2);
newHw1=Hw1(1:len1);
newHw2=Hw2(1:len1);

% compute the frequencies for the plots of Xw and Yw
k=0:(len1-1); % adjust vector to start counting from zero
w=k*(2*pi/length(Hw1)); % compute digital cyclic frequencies
W=w*fsampling; % revert to the analog cyclic frequencies
f=W/(2*pi); % find the analog frequencies
% create figure and adjust its width and height
fig = figure(1);
fig.Position = [500 300 700 500];
movegui(fig,'center');
% plot magnitude response of lowpass filter
subplot(211);
plot(f,abs(newHw1));
xticks([941 1209]);
xlabel('Frequency(Hz)');
ylabel('|H_{1}(\omega)|');
title('Magnitude response of lowpass filter h_{1}[n]');
% plot magnitude response of highpass filter
subplot(212);
plot(f,abs(newHw2));
xticks([941 1209]);
xlabel('Frequency(Hz)');
ylabel('|H_{2}(\omega)|');
title('Magnitude response of highpass filter h_{2}[n]');
end


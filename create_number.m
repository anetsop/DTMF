function [y,fsampling] = create_number(m)
% CREATE_NUMBER: takes a number(m) consisting of digits
% 0-9 and returns the corresponding DTMf signal(y)
% along with the sampling frequency(fsampling)

% split the number's (m) digits
% and store them in num
num = num2str(m);
num = num-'0';

% number of digits of m
numberOfDigits  = length(num);

fsampling = 8000; %sampling frequency
nDigit = 0:1/fsampling:(0.5-1/fsampling); %duration of one tone
nZero = 0:1/fsampling:(0.1-1/fsampling); %duration of space between tones
xZero = zeros(1,length(nZero)); %space between tones


% mapping each digit to a signal with two frequences based on
% mapfreq = [0   1209 1336 1477  1633; 
%            697    1    2    3   'A';
%            770    4    5    6   'B';
%            852    7    8    9   'C';
%            941  '*'    0  '#'   'D']

flistHigh = [1209 1336 1477  1633]; % list of high frequencies
flistLow = [697 770 852 941]; % list of low frequencies

% array of possible digits
digits = ['1' '2' '3' 'A'; 
           '4' '5' '6' 'B'; 
           '7' '8' '9' 'C'; 
           '*' '0' '#' 'D'];

y = []; %initialize output signal
% map each digit to signal 
% x[n] = cos(2pi*n*freqLow)+cos(2pi*n*freqHigh)
for i = 1:numberOfDigits
    % find row and column of each digit of the number
    [row,column] = find(digits == num2str(num(i)));
    % find the high frequency based on digits column
    % and low frequency based on digits row
    freqLow = flistHigh(column); 
    freqHigh = flistLow(row);
    % construct tone for current digit
    x = cos(2*freqLow*pi*nDigit)+cos(2*freqHigh*pi*nDigit);
    if i > 1
        % append a zero signal as a space between tones
        y = [y xZero];
    end
    y = [y x]; % append tone to the end of the output
end

% build the time scale of the output
upperbound = length(num)*0.6 - 0.1;
noutput = 0:1/fsampling:(upperbound-1/fsampling);

% find FFT of the output
N = 2^nextpow2(length(y));
Y = fft(y,N);
% take half the length of FFT to
% cut symmetrical peaks
len1=round(length(Y)/2);
newY=Y(1:len1);
k=0:(len1-1);

w=k*(2*pi/length(Y)); % find the digital cyclical frequencies
W=w*fsampling; % find the analog cyclical frequencies
f=W/(2*pi); % find the frequencies in Hz

% create figure and adjust its width and height
fig = figure(1);
fig.Position = [500 300 700 500];
movegui(fig,'center');
% plot the signal
subplot(211);
plot(noutput,y);
xlabel('Time(s)','FontSize',12);
ylabel('y[n]','FontSize',12);
title('DTMF signal y[n]','FontSize',12)

% plot the amplitude of the frequency response of the output(y)
subplot(212);
plot(f,abs(newY));
% adjust the tickmarks of the x-axis
xtickangle(90);
xticks([697 770 852 941 1209 1336 1477]);
ax=gca;
ax.FontSize = 7;
xlabel('Frequency(Hz)','FontSize',12);
ylabel('|Y(\omega)|','FontSize',12);
title('Amplitude spectrum of output signal y[n]','FontSize',12);

end


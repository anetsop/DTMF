clear;
clf;
% create DTMF signal and count its aces
m=5200900153;
[x,fs] = create_number(m);
close all;
aces = count_aces(x);

clear;
clf;
% create DTMF signal and filter digits 1,2 and 3
% out of it
m=5200900153;
[x,fs] = create_number(m);
close all;
[y,fs] = filter_number(x);

clear;
clf;
% read a DTMF signal and decode it 
% to find the number
[s,fs] = audioread('secret_number.wav');
close all;
number = decode_DTMF(s);

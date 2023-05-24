clear;
clf;
[s,fs] = audioread('secret_number.wav');
close all;
number = decode_DTMF(s);
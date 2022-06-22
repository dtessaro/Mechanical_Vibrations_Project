%% Clear
clear all;
close all;
clc;
fs = 51200;
%% Load Raw Data
window = [1.231445 2.697734];
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};
dataRaw.diff = dataRaw.acc1+dataRaw.acc2;
data = dataRaw(dataRaw.time>= 0 & dataRaw.time <= window(1),:);
%% Noise compute
x= data.acc1;
y = fft(x);
n = length(x);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT

plot(f,power)
xlabel('Frequency')
ylabel('Power')
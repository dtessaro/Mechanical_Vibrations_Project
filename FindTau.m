%% Clear
clear all;
close all;
clc;

%% Load Raw Data
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};

%% Compute
Max = max(abs(dataRaw.acc1));
s = size(dataRaw,1);
for i=1:s
i
    if max(abs(dataRaw.acc1(s-i:s))) >= 0.05*Max
        i
    break;
        while 1
        end
    end
end
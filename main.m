%% Clear
clear all;
close all;
clc;

%% Load Data

%time window
window = [1.23 1.4];
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','F','acc1','acc2'};

%extract meaningful time windows
data = dataRaw(dataRaw.time>= window(1) & dataRaw.time <= window(2),:);

%% Calc Data

%calc mean acceleration
data.acc = (data.acc1-data.acc2)/2;

%Back ground noise - mean noise whene there is't perturbation
mseData = dataRaw(dataRaw.time <= window(1) | dataRaw.time>= window(2),["time","acc1","acc2"]);
bgNoiseMean = mean(mseData{:,["acc1","acc2"]});  
MSE(1) = 2*mse(mseData.acc1,0);
MSE(2) = 2*mse(mseData.acc2,0);

%calc noise
data.noise = data.acc1+data.acc2;

%% Transfer function
fs = 1/data.time(1);
[Tf,Fr] = tfestimate(data.F,data.acc,[],[],[],fs);
Tm = abs(Tf);

%% Plot data
close all;
figure('Name','Raw data','NumberTitle','off');
plot(dataRaw.time,dataRaw.acc1);

figure('Name','Hummer Force','NumberTitle','off');
plot(data.time,data.F);

figure('Name','Acc1 & -Acc2','NumberTitle','off');
plot(data.time,data.acc1); hold on;
plot(data.time,-data.acc2); hold on; 
plot(data.time,data.noise); hold on;

figure('Name','Acceleration mean','NumberTitle','off');
plot(data.time,data.acc);
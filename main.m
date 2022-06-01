%% Clear
clear all;
close all;
clc;

%% Load Data
data = readtable('data.txt');
data.Properties.VariableNames = {'time','F','acc1','acc2'};

%% Plot data
interval = []

plot(data.time,data.F);

plot(data.time,data.acc1); hold on;
plot(data.time,data.acc2); 
set(gca, 'xlim', [-50 200]);
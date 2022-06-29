%% Clear
close all;
clear all;

%% Load Raw Data
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};
dataRaw = dataRaw(1:153600,:);
dataRaw.acc1 = abs(dataRaw.acc1);
%% Compute

for p=1:1
    Max = max(abs(dataRaw.acc1));
    s = size(dataRaw,1);
    [v,i] = findpeaks(dataRaw.acc1);
    pks =[v,i];
    %PKS = pks(v>=p*Max/100,:);
    PKS = pks(v>=0.05,:);
    lastPK = PKS(size(PKS,1),:);
    time = dataRaw.time(lastPK(2));
    fprintf("%d -> %d\n",p,time);
end

% 1% 1.4151
% 2% 
% 
% 
%
%% Clear
clear all;
close all;
clc;

%% Plot Settings

plot_dataRaw = false;
plot_hummer = false;
plot_data = true;
plot_FFT = true;
%% Load Data

%time window
window = [1.23 1.4];
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};

%extract meaningful time windows
data = dataRaw(dataRaw.time>= window(1) & dataRaw.time <= window(2),:);

%% Calc Data

%calc mean acceleration
data.acc = (data.acc1-data.acc2)/2;
data.acc_s = smoothdata(data.acc);
%calc noise
data.noise = data.acc1+data.acc2;

%% Experimental Transfer function

fs = 51200;
[Tf,Fr] = tfestimate(data.hum,data.acc,[],[],[],fs);
Tfm = abs(Tf);
[Tf_s,Fr_s] = tfestimate(data.hum,data.acc_s,[],[],[],fs);
Tfm_s = abs(Tf_s);
if plot_FFT
    figure('Name','Tm')
    plot(Fr,Tfm);
    plot(Fr_s,Tfm_s);
    xlabel('Frequency [Hz]')
    ylabel('Magnitude')
    axis([0 2000 0 100])
    grid on;
end

%% Plot data

if plot_dataRaw
    figure('Name','Raw data','NumberTitle','off');

    % Raw Plot
    t = tiledlayout(3,1);

    ax1 = nexttile;
    plot(ax1,dataRaw.time,dataRaw.hum)
    title(ax1,'Raw Hummer Force')
    ylabel('Force [N]');

    ax2 = nexttile;

    plot(ax2,dataRaw.time,dataRaw.acc1)
    title(ax2,'Raw Accelerometer 1')
    ylabel('Acc [m/s^2]');

    ax3 = nexttile;
    plot(ax3,dataRaw.time,dataRaw.acc2)
    title(ax3,'Raw Accelerometer 2')
    xlabel('Time [s]');
    ylabel('Acc [m/s^2]');
    grid on;

    linkaxes([ax1,ax2,ax3],'x');
end

%Hummer
if plot_hummer
    figure('Name','Hummer Force','NumberTitle','off');
    plot(data.time,data.hum);
    xlabel('Time [s]');
    ylabel('Force [N]');
end

%Acc1 -Acc2 Acc1+Acc2 MeanAcc
if plot_data
    figure('Name','Acc1 & -Acc2','NumberTitle','off');
    plot(data.time,data.acc1); hold on;
    plot(data.time,-data.acc2); hold on; 
    plot(data.time,data.noise); hold on;
    plot(data.time,data.acc);
    grid on;
    legend('Acc1','-Acc2','Acc1+Acc2', 'Mean Acc');
    xlabel('Time [s]');
    ylabel('Acceleration [m/s^2]');
end

%% Clear
clear all;
close all;
clc;

%% Plot Settings
plot_dataRaw    = 0;
plot_hummer     = 0;
plot_FFT        = 1;

plot_data = 1;
    plot_data_acc1      = 0;
    plot_data_acc2      = 0;
    plot_data_diff      = 1; 
    plot_data_acc_mean  = 1;
    
%% Other settings
%time window
window = [1.23 1.4];
fs = 51200;
%% Load Raw Data
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};

%% Calc Data

%extract meaningful time windows
data = dataRaw(dataRaw.time>= window(1) & dataRaw.time <= window(2),:);
%compute mean acceleration betwwen 2 accelerometer data
data.acc_mean = (data.acc1-data.acc2)/2;
%compute diff with the difference between 2 accelerometer
data.diff = data.acc1+data.acc2;
data.smooth = smooth(data.acc_mean);

%% Experimental Transfer function

d= table(data.time,data.hum,data.acc_mean,data.smooth,'VariableNames',{'time','hum','acc','smooth'});

[Tf,Fr] = tfestimate(d.hum,d.acc,[],[],[],fs);
TF = table(Fr,Tf,abs(Tf),angle(Tf),'VariableNames',{'fr','tf','mod','phase'});

%find the peak
[peak,peak_f] = findpeaks(TF.mod);
peak = [peak,TF.fr(peak_f)];
peak = sortrows(peak,1,'descend');
peak = peak(1:3,:);

%% Estimate damping ratio with half power point method

x0 = 1
g=2
sol = fsolve(@(x) interp1(TF.fr,TF.mod,x,'spline')-g,x0);
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


%Plot data
if plot_data
    leg = [];
    figure('Name','data','NumberTitle','off');
    if plot_data_acc1
        plot(data.time,data.acc1); hold on;
        leg = [leg, "Acc1"];
    end
    if plot_data_acc2
        plot(data.time,-data.acc2); hold on; 
        leg = [leg, "-Acc2"];
    end
    if plot_data_diff
        plot(data.time,data.diff); hold on;
        leg = [leg, "Noise"];
    end
    if plot_data_acc_mean
        plot(data.time,data.smooth); hold on;
        leg = [leg, "Acc Mean"];
    end


    grid on;
    legend(leg);
    xlabel('Time [s]');
    ylabel('Acceleration [m/s^2]');
end

%Plot FFT
if plot_FFT
   
    figure('Name','Trunsfer Function','NumberTitle','off');

    t = tiledlayout(2,1);

    ax1 = nexttile;
    plot(ax1,TF.fr,TF.mod); hold on;
    plot([peak(1,2),peak(1,2)],[peak(1,1),0],'r');
    plot([peak(2,2),peak(2,2)],[peak(2,1),0],'r');
    plot([peak(3,2),peak(3,2)],[peak(3,1),0],'r');
    plot([0,2000],[g,g],'r');
    title(ax1,'Magnitude')
    ylabel('Module');

    ax2 = nexttile;

    plot(ax2,TF.fr,TF.phase)
    title(ax2,'Phase')
    ylabel('Phase');

    xlabel('Frequency [Hz]');
    
    grid on;

    linkaxes([ax1,ax2],'x');
    xlim([0 2000])
end

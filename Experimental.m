%% Clear
clear all;
close all;
clc;

%% Plot Settings
plot_dataRaw    = 0;
plot_hammer     = 0;
plot_FFT        = 1;

plot_data = 1;
    plot_data_acc1      = 1;
    plot_data_acc2      = 1;
    plot_data_diff      = 1; 
    plot_data_acc_mean  = 0;
export = 1;    
%% Other settings
%time window
window = [1.231445 2.697734];
fs = 51200;
%% Load Raw Data
dataRaw = readtable('data.txt');
dataRaw.Properties.VariableNames = {'time','hum','acc1','acc2'};

%% Calc Data

%extract meaningful time windows
data = dataRaw(dataRaw.time>= window(1) & dataRaw.time <= window(2),:);
data.acc2 = -data.acc2;
%compute mean acceleration betwwen 2 accelerometer data
data.acc_mean = (data.acc1+data.acc2)/2;
%compute diff with the difference between 2 accelerometer
data.diff = data.acc1-data.acc2;
data.smooth = smooth(data.acc_mean);

%% Experimental Transfer function

d= table(data.time,data.hum,data.acc_mean,data.diff,'VariableNames',{'time','hum','acc','diff'});
[Tf,Fr] = tfestimate(d.hum,d.acc_mean,[],[],[],fs);
TF = table(Fr,Tf,abs(Tf),angle(Tf),'VariableNames',{'fr','tf','mod','phase'});

%find the peak
[peak,peak_f] = findpeaks(TF.mod(1:500));
peak = [peak,TF.fr(peak_f)];
peak = sortrows(peak,1,'descend');
peak = peak(1:3,:);

%% Estimate damping ratio with half power point method

x0 = 1
g=2
sol = fsolve(@(x) interp1(TF.fr,TF.mod,x,'spline')-g,x0);
%% Plot data
close all;
if plot_dataRaw
    graph = figure('Name','Raw data','NumberTitle','off');

    % Raw Plot
    t = tiledlayout(3,1);

    ax1 = nexttile;
    plot(ax1,dataRaw.time,dataRaw.hum)
    title(ax1,'Hammer Force')
    ylabel('Force [N]');
    grid on;
    ax2 = nexttile;

    plot(ax2,dataRaw.time,dataRaw.acc1)
    title(ax2,'Accelerometer 1')
    ylabel('Acc [m/s^2]');
    grid on;
    ax3 = nexttile;
    plot(ax3,dataRaw.time,dataRaw.acc2)
    title(ax3,'Accelerometer 2')
    xlabel('Time [s]');
    ylabel('Acc [m/s^2]');
    grid on;

    linkaxes([ax1,ax2,ax3],'x');
    if export
        exportgraphics(graph,'graphs/Raw Data.pdf')
    end
end

%Hammer
if plot_hammer
    graph=figure('Name','Hammer Force','NumberTitle','off');
    plot(data.time,data.hum);
    xlabel('Time [s]');
    ylabel('Force [N]');
    if export
        exportgraphics(graph,'graphs/Hammer.pdf')
    end
end


%Plot data
if plot_data
    leg = [];
    graph=figure('Name','data','NumberTitle','off');
    if plot_data_acc1
        plot(data.time,data.acc1,'Color','#D95319'); hold on;
        leg = [leg, "Acc1"];
    end
    if plot_data_acc2
        plot(data.time,data.acc2,'Color','#0072BD'); hold on; 
        leg = [leg, "Acc2"];
    end
    if plot_data_diff
        plot(data.time,data.diff); hold on;
        leg = [leg, "Acc Diff"];
    end
    if plot_data_acc_mean
        plot(data.time,data.smooth);
        leg = [leg, "Acc Mean"];
    end


    grid on;
    legend(leg);
    xlabel('Time [s]');
    ylabel('Acceleration [m/s^2]');
    xlim([1.23 1.33]);
    if export
        exportgraphics(graph,'graphs/PlotData.pdf')
    end
end

%Plot FFT
if plot_FFT
   
    graph=figure('Name','Trunsfer Function','NumberTitle','off');
    plot(TF.fr,TF.mod); hold on;
    
    xlim([0 1600])
    xlabel('Frequency [Hz]');
    ylabel('$\vert$ G(f) $\vert$','interpreter','latex');
    grid on;

    if export
        exportgraphics(graph,'graphs/FFT.pdf')
    end
end

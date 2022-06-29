%% Clear
clear all;
close all;
clc

%% Plot Settings
plot_dataRaw    = 0;
plot_hammer     = 0;
plot_FFT        = 1;

plot_data = 0;
    plot_data_acc1      = 0;
    plot_data_acc2      = 0;
    plot_data_diff      = 0; 
    plot_data_acc_mean  = 1;
export = 1;    
%% Other settings
% %time window
% 1% ->  1.415
% 2% ->  1.361
sumPeak = [0,0];
for kkk=1:10
window = [1.231445 1.4+kkk*0.1];

fs = 51200;
fn_a = [124.4, 497.16, 1119.63];
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
[Tf,Fr] = tfestimate(d.hum,d.acc,[],[],[],fs);
TF = table(Fr,Tf,abs(Tf),angle(Tf),'VariableNames',{'fr','tf','mod','phase'});
%find the peak
[peaks,peak_f] = findpeaks(TF.mod);
peaks = [peaks,TF.fr(peak_f)];

peak = [];
for i=1:3
    L =[];
    ep = 1;
    while size(L,1)==0
        L = peaks(:,2) <= fn_a(i)+ep & peaks(:,2) >= fn_a(i)-ep  & peaks(:,1)>= 15;
        L = find(L);
        ep = ep+1;
    end
    peak(i,:) = peaks(L,:);
end
if sum(peak(:,1)) >= sumPeak(1)
    sumPeak = [sum(peak(:,1)), window(2)];
end
%% Estimate damping ratio with half power point method

xi = [];
for i=1:size(peak,1)
    g = peak(i,1)/sqrt(2);
    x0 = peak(i,2)-1;
    w1 = fsolve(@(x) interp1(TF.fr,TF.mod,x,'spline')-g,x0);
    x0 = peak(i,2)+1;
    w2 = fsolve(@(x) interp1(TF.fr,TF.mod,x,'spline')-g,x0);
    xi = [xi , (w2-w1)/peak(i,2)];
end

%% Natural frequency
for i=1:size(peak,1)
    wn(i) = peak(i,2)/sqrt(1-xi(i)^2) ;
end


%% Plot data
%close all;
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
        plot(data.time,data.smooth); hold on;
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

%Plot TF
%if plot_FFT
    if kkk == 1
    title = sprintf('TF [%2.3f ; %2.3f]',window(1),window(2));
    graph=figure('Name',title,'NumberTitle','off');
    end
    plot(TF.fr,TF.mod); hold on;
    leg(kkk,:) =sprintf("[%1.1f ; %1.1f]",window(1),window(2));
%      for i=1:3
%          plot([fn_a(i) fn_a(i)], [0 peak(i,1)],'r'); hold on;
%          plot([peak(i,2) peak(i,2)], [0 peak(i,1)],'k'); hold on;
%      end
end
    xlim([0 1600])
    xlabel('Frequency [Hz]');
    ylabel('$\vert$ G(f) $\vert$','interpreter','latex');
    legend(leg);
    grid on;

    if export
        exportgraphics(graph,'graphs/FFT.pdf')
    end
%end


xlabel('f (Hz)')
ylabel('|P1(f)|')
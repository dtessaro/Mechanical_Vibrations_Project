%% Clear
clear all;
close all;
clc;

%% Beam Data
Xi=[0.05, 0.01, 0.01]; %Damping 

E = 206e+3; %Young modulus  [Pa]
p = 7850;   %Mass density   [1/m^3]
A = 111;    %Cross-section  [mm^2]
L = 0.7;    %Lenght         [m]
I = 6370; %                 [mm^4]
%% Computation

beta = (pi/L);
beta = [beta ; beta*2 ; beta*3];
alfa = beta*L;
wn=  beta.^2 *sqrt(E*I/(p*A));
time = 0:0.00002:1;
x = 0:0.00001:L;
for i=1:3
    modes(i,:) = i*sin(beta(i)*x)+i*sin(beta(i)*L)/sinh(beta(i)*L)*sinh(beta(i)*x);
end

%% Plot

graph = figure('Name','Modes','NumberTitle','off');
% Modes Plot
t = tiledlayout(3,1);

ax1 = nexttile;
plot(ax1,x,modes(1,:))
title(ax1,'Mode 1')
ylabel('$y$','Interpret','latex');
grid on;
ax2 = nexttile;

plot(ax2,x,modes(2,:))
title(ax2,'Mode 2')
ylabel('$y$','Interpret','latex');
grid on;
ax3 = nexttile;
plot(ax3,x,modes(3,:))
title(ax3,'Mode 3')
xlabel('$x$ [m]','Interpret','latex');
ylabel('$y$','Interpret','latex');
grid on;

linkaxes([ax1,ax2,ax3],'x');

exportgraphics(graph,'graphs/ModeShapes.pdf')
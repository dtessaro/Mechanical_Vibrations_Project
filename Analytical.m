%% Clear
clear all;
close all;
clc;

%% Beam Data
Xi=[0.05, 0.01, 0.01]; %Damping 

E = 206e+9; %Young modulus  [Pa]
p = 7850;   %Mass density   [1/m^3]
A = 111;    %Cross-section  [mm^2]
L = 0.7;    %Lenght         [m]

%% Variables
syms x b I;
syms C1 C2 C3 C4;

%% Computation

%W functions ad second derivative
W(x) = C1*cos(b*x) + C2*sin(b*x) + C3*cosh(b*x) + C4*sinh(b*x);
W2 = diff(diff(W,x),x);
%Boundaries
bounds = [     W(0) ==0;
           E*I*W2(0)==0;
               W(L) ==0;
           E*I*W2(L)==0];
C = [C1,C2,C3,C4,b];
C = solve(bounds,C,'PrincipalValue',false);
b = C[5]
C = [C.C1 C.C2 C.C3 C.C4]

det(b)= sin(b*L)+sinh(b*L) == 0;
b = 0;


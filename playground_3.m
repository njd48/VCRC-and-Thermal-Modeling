%% Initialize
format compact
format long
clear all
close all

% Sim Param 
epsilon = 0.00001;

load param_4.mat
% Phys Param
%N      = 5000;
valve  = 0.725;
T_amb  = 40;
T_pod  = 17;


Q_load = 2.000;  %kJ


% Init
T_SH   = 0;
P_c  = 3300;
P_e  = 1000;

Vars_i  = [ P_c; P_e; T_SH ]; 
Inputs  = [ Q_load; valve; T_amb; T_pod  ];
Param   = [ RPM, CA ]; 

%% Test make cycle function

[P,T,h,z, m_dot, Q_L, Q_H, W, deficit] = make_cycle(Vars_i, Inputs, Param);

figure(1)
plotcycle_PH( P, h, 'cyclecolor', 'r')

figure(2)
%dome
DrawDome('T','s','type','linear'), hold on
%draw cycle environment lines
env_c = T_amb*[1,1];
env_e = T_pod*[1,1];
sssss = [0.6, 2.2];
plot(sssss,env_e,'--c')
plot(sssss,env_c,'--m')

    for j = 1:numel(P)

        s(j) = XR410a('s','Ph', P(j), h(j) );
        
    end
%first pass
pwe1 = plot(s,T,'-or','linewidth',2);
hold off
grid on
ylim([-15, 80])

figure(3)
plot(z, T, '-or','linewidth',2)
xlabel('HX position, z, nondim')
ylabel('T (*C)')
grid on


%% First attempt to adjust pressures


%Make init cycle
[P1,T1,h1,z1, m1,QL1,QH1,W1,  Deficit_1] = make_cycle(Vars_i, Inputs, Param);

%adjust vars
%Keep history

N = 7;
Vars_2   = Vars_i;

var_hist = zeros(3,N+1);
var_hist(:,1) = Vars_i;

def_hist = var_hist;
def_hist(:,1) = Deficit_1;

for n = 1:N
   
    Vars_2 = adjust_cycle(Vars_2, Inputs, Param, epsilon);
    var_hist(:,n+1) = Vars_2;
    
end

%Make final cycle
[P2,T2,h2,z2,m2,QL2,QH2,W2,  Deficit_2] = make_cycle(Vars_2, Inputs, Param);

%
%
%
%Visualization of data
%


figure(1)
%dome
plotcycle_PH( P2, h2, 'cyclecolor','r','stationlabels')

figure(2)
    s2 = 0*h2;
    for j = 1:numel(P2)
        s2(j) = XR410a('s','Ph', P2(j), h2(j) ); 
    end
plotcycle_TS( T2, s2, 'T_env',T_amb,T_pod,'cyclecolor','r','stationlabels')

figure(3)
plot(z2, T2, '-or','linewidth',2)
xlabel('HX position, z, nondim')
ylabel('T (*C)')
grid on


disp(datetime('now'))
disp('init. Deficit ')
disp(Deficit_1)
disp('final Deficit ')
disp(Deficit_2)
disp('Heat kW')
disp(QL2)

